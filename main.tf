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

provider "aws" {
  region = "us-east-1"
  alias  = "us_east_1"
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
  tags        = merge(module.label.tags, { "data_sensitivity" : "low" })

}

module "cloudfront_cdn" {
  source = "./modules/cloudfront_cdn"

  name_prefix = module.label.id
  tags        = module.label.tags

  cloudfront_access_identity_path = module.s3_bucket.cloudfront_access_identity_path
  bucket_regional_domain_name     = module.s3_bucket.bucket_regional_domain_name
  bucket_name                     = module.s3_bucket.bucket_name
  domain_name                     = local.domain_name
  acm_certificate_arn             = aws_acm_certificate_validation.cert.certificate_arn

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}