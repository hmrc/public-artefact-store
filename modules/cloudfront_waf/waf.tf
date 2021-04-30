# please note as this is a public repo please only add rules that you wish to be known i.e rate-limit

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

  rule {
    name     = "GeneralRateLimit"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = (100 * 60 * 5) # 100 requests per second in a 5-minute time span
        aggregate_key_type = "IP"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
      metric_name                = "GeneralRateLimit"
    }
  }
}

