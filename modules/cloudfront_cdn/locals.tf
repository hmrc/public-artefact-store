locals {
    aws_resource_safe_domain_name = replace(var.domain_name, ".", "-")
}
