terraform {
  required_version = "~> 0.14.3"

  backend "s3" {
    key            = "public-artefact-store/v1/state"
    region         = "eu-west-2"
    dynamodb_table = "mdtp-terraform-public-artefact-store"
  }

  required_providers {
    aws = "<= 3.16.0"
  }
}

provider "aws" {
  region = "eu-west-2"
}

module "label" {
  source  = "cloudposse/label/terraform"
  version = "0.5.1"

  namespace = "mdtp"
  stage     = terraform.workspace
  name      = "public-artefact-store"

  tags = {
    env        = terraform.workspace
    team       = "build-and-deploy"
    managed-by = "https://github.com/hmrc/public-artefact-store"
  }
}

module "s3_bucket" {
  source      = "./modules/s3_bucket"
  bucket_name = module.label.id
  tags        = module.label.tags
}