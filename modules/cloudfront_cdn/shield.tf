resource "aws_shield_protection" "example" {
  name         = var.name_prefix
  resource_arn = aws_cloudfront_distribution.website.arn
}
