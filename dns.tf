locals {
  environment_subdomain = terraform.workspace == "live" ? "" : "${terraform.workspace}."
  parent_domain = "${local.environment_subdomain}artefacts.tax.service.gov.uk"
  subdomain = "open"
}

data "aws_secretsmanager_secret_version" "zone_id" {
  secret_id = "/shared_secret/dns/${local.parent_domain}/zone-id"
}

resource "aws_route53_record" "website" {
  name = local.subdomain
  type = "A"
  zone_id = data.aws_secretsmanager_secret_version.zone_id.secret_string

  alias {
    name = module.cloudfront_cdn.domain_name
    zone_id = module.cloudfront_cdn.hosted_zone_id
    evaluate_target_health = false
  }
}