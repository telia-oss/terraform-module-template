terraform {
  required_version = ">= 0.14"
}

provider "aws" {
  region = var.region
}

module "template" {
  source      = "../../"
  name_prefix = var.name_prefix

  tags = {
    environment = "dev"
    terraform   = "True"
  }
}
