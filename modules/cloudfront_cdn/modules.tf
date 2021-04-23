module "cloudfront-logs" {
  source      = "fmasuhr/cloudfront-logs/aws"
  version     = "1.3.1"
  bucket_name = "${local.aws_resource_safe_domain_name}-access-logs"
  name        = "${local.aws_resource_safe_domain_name}-access-logs"
  retention   = 365
  tags        = var.tags
}
