#!/usr/bin/env bash

set -euo pipefail

SRC=$PWD
REF=$(git rev-parse --short HEAD)

main() {
    set +u
    TAR="${1}"
    set -u

    if [ ! -d "${TAR}" ];then
        echo "usage: ./update.sh DIRECTORY"
        exit 1
    fi

    cd "${TAR}"
    git checkout master
    git pull

    if [ ! -d "${TAR}/.github" ]; then
        # Copy entire directory if it does not exist.
        cp -r "${SRC}/.github" "${TAR}/.github"
    else
        # Reset ISSUE_TEMPLATE and workflow
        rm -rf "${TAR}/.github/ISSUE_TEMPLATE"
        rm -rf "${TAR}/.github/workflows"

        cp -r "${SRC}/.github/ISSUE_TEMPLATE" "${TAR}/.github/ISSUE_TEMPLATE"
        cp -r "${SRC}/.github/workflows" "${TAR}/.github/workflows"
    fi

    if [ -f "${TAR}/CODEOWNERS" ]; then
        # Move existing CODEOWNERS to .github
        mv "${TAR}/CODEOWNERS" "${TAR}/.github/CODEOWNERS"
    elif [ ! -f "${TAR}/.github/CODEOWNERS" ]; then
        # Copy template if it does not exist at all
        cp "${SRC}/.github/CODEOWNERS" "${TAR}/.github/CODEOWNERS"
    fi

    # Update .gitignore
    cp "${SRC}/.gitignore" "${TAR}/.gitignore"

    # Update taskfile
    cp "${SRC}/Taskfile.yml" "${TAR}/Taskfile.yml"

    # Add a license if missing
    if [ ! -f "${TAR}/LICENSE" ]; then
        cp "${SRC}/LICENSE" "${TAR}/LICENSE"
    fi

    # Remove unused files
    set +e
    for f in .travis.yml Makefile STYLE.md CONTRIBUTING.md .github/PULL_REQUEST_TEMPLATE.md; do
        rm "${TAR}/${f}" 2> /dev/null
    done

    # Remove old test harness
    rm -rf "${TAR}/.ci" 2> /dev/null
    for f in "${TAR}"/examples/*/test.sh; do
        rm "${f}" 2> /dev/null
    done
    set -e

    # Add a readme if missing
    if [ ! -f "${TAR}/README.md" ]; then
        cp "${SRC}/README.md" "${TAR}/README"
    fi

    # Remove maintained shield from README.
    sed -i '' -E "/.*img\.shields\.io\/maintenance\/yes.*/d" "${TAR}/README.md"

    # Replace travis badge in readme
    REPO=$(basename "${TAR}")
    LINK="[![workflow](https://github.com/telia-oss/${REPO}/workflows/workflow/badge.svg)](https://github.com/telia-oss/${REPO}/actions)"
    sed -i '' -E "s#\[!.*travis-ci\.(com|org).*#${LINK}#g" "${TAR}/README.md"

    # Add terratest scaffold if missing
    if [ ! -d "${TAR}/test" ]; then
        cp -r "${SRC}/test" "${TAR}/test"
    fi

    # Fix go module
    if [ ! -f "${TAR}/go.mod" ]; then
        go mod init
    fi
    # Build (update dependencies) and tidy
    go build ./test
    go mod tidy

    # Add examples if missing
    for d in examples/basic examples/complete; do
        if [ ! -d "${TAR}/${d}" ]; then
            set +e
            rm -rf "${SRC}/${d}/.terraform" && rm "${SRC}/${d}/terraform.tfstate*"
            set -e
            cp -r "${SRC}/${d}" "${TAR}/${d}"
        else
            cp "${SRC}/${d}/README.md" "${TAR}/${d}/README.md"
        fi
    done

    if [[ -n $(git ls-files -m) ]]; then 
        git checkout -B module-template-updates
        git add .
        git commit -m "Updates from module template: ${REF}"
    fi
}

main $1
