resource "aws_shield_protection" "website" {
  name         = var.name_prefix
  resource_arn = var.cloudfront_distribution_arn
  tags = var.tags
}

# associate-health-check is not yet supported by terraform...yet
resource "null_resource" "associate-health-check" {
  triggers = {
    aws_shield_protection        = aws_shield_protection.website.id
    aws_route53_health_check_arn = "arn:aws:route53:::healthcheck/${aws_route53_health_check.website.id}"
  }
  provisioner "local-exec" {
    command = "aws shield associate-health-check --protection-id ${self.triggers.aws_shield_protection} --health-check-arn ${self.triggers.aws_route53_health_check_arn}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "aws shield disassociate-health-check --protection-id ${self.triggers.aws_shield_protection} --health-check-arn ${self.triggers.aws_route53_health_check_arn}"
  }

  depends_on = [
    aws_shield_protection.website,
    aws_route53_health_check.website
  ]
}

resource "aws_route53_health_check" "website" {
  fqdn              = var.domain_name
  port              = 443
  type              = "HTTPS"
  resource_path     = "/"
  failure_threshold = "5"
  request_interval  = "30"
  measure_latency   = true

  tags = var.tags
}
