resource "aws_acm_certificate" "cert" {
  provider = aws.us_east_1

  domain_name       = local.domain_name
  tags              = module.label.tags
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "cert" {
  provider        = aws.us_east_1
  certificate_arn = aws_acm_certificate.cert.arn
}
