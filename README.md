

## Instructions for this Terraform template

Use this module template to scaffold a new one. Remember to change the following:

- [ ] The descriptions and build badges in this [README](README).
- [ ] Any examples in this section [examples](#examples).
- [ ] Update [pipeline.yml](.ci/pipeline.xml) to reflect repo to be tested and add tests for additional examples.
- [ ] Update [CODEOWNERS](CODEOWNERS).


# Terraform Template Module

[![Build Status](https://travis-ci.com/telia-oss/terraform-module-template.svg?branch=master)](https://travis-ci.com/telia-oss/terraform-module-template)
![](https://img.shields.io/maintenance/yes/2018.svg)

Terraform module which creates *describe your intent* resources on AWS.

## Examples

* [Simple Example](examples/default/main.tf)

Note: test.sh is intended to be run by the CI pipeline and can expect to find the output of `terraform output -json` in a 
file at the relative location `terraform-out/terraform-out.json`

## CI Pipeline
* [pipeline.yml](.ci/pipeline.yml)

The CI pipeline does the following for each example
1. runs terraform apply
1. runs the test.sh file for the example
1. runs terraform destroy

To do this each example has remote state. All account specific details and secrets are injected by the pipeline when it 
is run.
## Authors

Currently maintained by [these contributors](../../graphs/contributors).

## License

MIT License. See [LICENSE](LICENSE) for full details.