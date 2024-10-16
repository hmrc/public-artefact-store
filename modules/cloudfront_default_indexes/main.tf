terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5.22.0"
      configuration_aliases = [aws.us_east_1]
    }
  }
}

resource "aws_cloudfront_function" "rewrite_index" {
  name    = "RewriteDefaultIndexRequest"
  runtime = "cloudfront-js-2.0"
  comment = "RewriteDefaultIndexRequest"
  publish = true
  code    = file("${path.module}/RewriteDefaultIndexRequest.js")
}

resource "aws_cloudwatch_log_group" "viewer_request_function_logs" {
  provider          = aws.us_east_1
  name              = "/aws/cloudfront/function/RewriteDefaultIndexRequest"
  retention_in_days = 7
  tags              = var.tags
}