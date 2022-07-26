module "bucket" {
  source  = "git@github.com:hmrc/terraform-aws-s3-bucket-standard?ref=1.3.0"

  bucket_name   = "${var.name_prefix}-waf-acl-logs"
  force_destroy = false

  list_roles          = [aws_iam_role.firehose_role.arn]
  read_roles          = [aws_iam_role.firehose_role.arn]
  write_roles         = [aws_iam_role.firehose_role.arn]
  metadata_read_roles = []
  admin_roles         = []

  read_services = ["drt.shield.amazonaws.com"]
  list_services = ["drt.shield.amazonaws.com"]

  data_expiry      = "1-month"
  data_sensitivity = "low"

  log_bucket_id = "${terraform.workspace == "live" ? "build-live-access-logs" : "build-labs-access-logs"}"
  tags          = var.tags
}
