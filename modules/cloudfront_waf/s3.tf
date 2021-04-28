resource "aws_s3_bucket" "waf_acl_log" {
  bucket = "${var.name_prefix}-waf-acl-logs"
  acl    = "private"
  tags   = var.tags

  lifecycle_rule {
    enabled = true
    id      = "DeleteOldLogs"
    expiration {
      days = 30
    }
  }

  versioning {
    enabled = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.waf_acl.id
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "waf_acl_log" {
  bucket                  = aws_s3_bucket.waf_acl_log.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket     = aws_s3_bucket.waf_acl_log.bucket
  policy     = data.aws_iam_policy_document.bucket_iam_policy.json
  depends_on = [aws_s3_bucket.waf_acl_log]
}

data "aws_iam_policy_document" "bucket_iam_policy" {

  statement {
    sid    = "AllowDDoSResponseTeamAccess"
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "drt.shield.amazonaws.com",
      ]
    }

    actions = [
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.waf_acl_log.arn,
      "${aws_s3_bucket.waf_acl_log.arn}/*",
    ]
  }

  statement {
    sid    = "AllowRead"
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        aws_iam_role.firehose_role.arn,
      ]
    }

    actions = [
      "s3:List*",
      "s3:Get*",
    ]

    resources = [
      aws_s3_bucket.waf_acl_log.arn,
      "${aws_s3_bucket.waf_acl_log.arn}/*",
    ]
  }

  statement {
    sid    = "AllowWrite"
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        aws_iam_role.firehose_role.arn
      ]
    }

    actions = [
      "s3:Put*",
    ]

    resources = [
      aws_s3_bucket.waf_acl_log.arn,
      "${aws_s3_bucket.waf_acl_log.arn}/*",
    ]
  }

  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:*",
    ]

    resources = [
      aws_s3_bucket.waf_acl_log.arn,
      "${aws_s3_bucket.waf_acl_log.arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    sid    = "ForceDefaultEncryptionTypePolicy"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = ["${aws_s3_bucket.waf_acl_log.arn}/*"]

    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["false"]
    }
  }

}

data "aws_iam_policy_document" "kms_policy" {

  statement {
    sid    = "AllowDDosResponseTeamDecrypt"
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "drt.shield.amazonaws.com",
      ]
    }

    actions = [
      "kms:Decrypt",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowDecrypt"
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        aws_iam_role.firehose_role.arn,
      ]
    }

    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "KeyManagement"
    effect = "Allow"
    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
      type        = "AWS"
    }
    actions = [
      "kms:*"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_kms_key" "waf_acl" {
  description             = "${var.name_prefix}-web-acl-log-key"
  deletion_window_in_days = 7
  policy                  = data.aws_iam_policy_document.kms_policy.json
  tags                    = var.tags
}