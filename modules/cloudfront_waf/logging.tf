resource "aws_wafv2_web_acl_logging_configuration" "waf_acl" {
  provider                = aws.us_east_1
  log_destination_configs = [aws_kinesis_firehose_delivery_stream.waf_acl.arn]
  resource_arn            = aws_wafv2_web_acl.waf_acl.arn
}

resource "aws_kinesis_firehose_delivery_stream" "waf_acl" {
  provider    = aws.us_east_1
  name        = "aws-waf-logs-${var.name_prefix}"
  destination = "extended_s3"

  server_side_encryption {
    enabled = true
  }

  extended_s3_configuration {
    role_arn           = aws_iam_role.firehose_role.arn
    bucket_arn         = aws_s3_bucket.waf_acl_log.arn
    compression_format = "GZIP"
  }
}

resource "aws_iam_role" "firehose_role" {
  name               = "${var.name_prefix}-waf-firehose-role"
  assume_role_policy = data.aws_iam_policy_document.firehose_principal.json
}

data "aws_iam_policy_document" "firehose_principal" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "firehose.amazonaws.com"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values = [
        data.aws_caller_identity.current.account_id
      ]
    }
  }
}