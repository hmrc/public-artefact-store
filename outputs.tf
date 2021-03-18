output "cdn_domain_name" {
  value = "https://${module.cloudfront_cdn.domain_name}"
}

output "domain_name" {
  value = "https://${aws_route53_record.website.fqdn}"
}
