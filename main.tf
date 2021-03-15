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