resource "aws_wafv2_web_acl" "waf_acl" {
  provider = aws.us_east_1

  name  = var.name_prefix
  scope = "CLOUDFRONT"

  default_action {
    allow {}
  }

  tags = var.tags

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = var.name_prefix
    sampled_requests_enabled   = true
  }
}
