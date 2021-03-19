output "cdn_domain_name" {
  value = "https://${module.cloudfront_cdn.domain_name}"
}

output "expected_domain_name" {
  value = "https://${local.domain_name}"
}
