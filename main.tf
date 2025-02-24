terraform {
  required_version = "~> 1.9.7"

  backend "s3" {
    key            = "public-artefact-store/v1/state"
    region         = "eu-west-2"
    dynamodb_table = "mdtp-terraform-public-artefact-store"
  }

  required_providers {
    aws = ">= 5.22.0"
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
  version = "0.8.0"

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

module "cloudfront_default_indexes" {
  source      = "./modules/cloudfront_default_indexes"
  name_prefix = module.label.id
  tags        = module.label.tags
  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1

  }
}

module "cloudfront_waf" {
  source = "./modules/cloudfront_waf"

  name_prefix = module.label.id
  tags        = module.label.tags

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}

module "cloudfront_cdn" {
  source = "./modules/cloudfront_cdn"

  name_prefix = module.label.id
  tags        = module.label.tags

  web_acl_arn                       = module.cloudfront_waf.web_acl_arn
  cloudfront_access_identity_path   = module.s3_bucket.cloudfront_access_identity_path
  bucket_regional_domain_name       = module.s3_bucket.bucket_regional_domain_name
  bucket_name                       = module.s3_bucket.bucket_name
  domain_name                       = local.domain_name
  acm_certificate_arn               = aws_acm_certificate_validation.cert.certificate_arn
  viewer_request_function_arn       = module.cloudfront_default_indexes.function_arn

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

}

module "cloudfront_shield" {
  source = "./modules/cloudfront_shield"

  name_prefix = module.label.id
  tags        = module.label.tags

  cloudfront_distribution_arn = module.cloudfront_cdn.cloudfront_distribution_arn
  domain_name                 = local.domain_name
}

data "aws_secretsmanager_secret_version" "build_account_ids" {
  secret_id = "/share-secret/build-account-ids"
}

module "share_cloudfront_distribution_id" {
  source              = "./modules/share_secret"
  secret_name         = "/shared-secret/${local.domain_name}/cloudfront_distribution_id"
  secret_value        = module.cloudfront_cdn.cloudfront_distribution_id
  tags                = module.label.tags
  allowed_account_ids = jsondecode(data.aws_secretsmanager_secret_version.build_account_ids.secret_string)
}
