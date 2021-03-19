locals {
  environment_subdomain = terraform.workspace == "live" ? "" : "${terraform.workspace}."
  domain_name           = "open.${local.environment_subdomain}artefacts.tax.service.gov.uk"
  allowed_account_ids   = jsondecode(data.aws_secretsmanager_secret_version.webops_account_ids.secret_string)
}

data "aws_secretsmanager_secret_version" "webops_account_ids" {
  secret_id = "/share-secret/${local.domain_name}/webops-account-ids"
}

module "share_domain_name" {
  source              = "./modules/share_secret"
  secret_name         = "/shared-secret/dns/open.lab03.artefacts.tax.service.gov.uk/domain_name"
  secret_value        = module.cloudfront_cdn.domain_name
  allowed_account_ids = local.allowed_account_ids
  tags                = module.label.tags
}

module "share_zone_id" {
  source              = "./modules/share_secret"
  secret_name         = "/shared-secret/dns/open.lab03.artefacts.tax.service.gov.uk/zone_id"
  secret_value        = module.cloudfront_cdn.hosted_zone_id
  allowed_account_ids = local.allowed_account_ids
  tags                = module.label.tags
}

resource "aws_acm_certificate" "cert" {
  domain_name               = local.domain_name
  tags                      = module.label.tags
  validation_method         = "DNS"
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn = aws_acm_certificate.cert.arn
}

module "share_cert_validation_record" {
  source              = "./modules/share_secret"
  secret_name         = "/shared-secret/dns/open.lab03.artefacts.tax.service.gov.uk/cert-validation-record-array"
  secret_value        = jsonencode(aws_acm_certificate.cert.domain_validation_options)
  allowed_account_ids = local.allowed_account_ids
  tags                = module.label.tags
}
