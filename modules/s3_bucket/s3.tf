resource "aws_s3_bucket_public_access_block" "website" {
  bucket                  = var.bucket_name
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

locals {
  account_name = terraform.workspace == "live" ? terraform.workspace : "labs"
}

module "bucket" {
  source      = "git@github.com:hmrc/terraform-aws-s3-bucket-core?ref=1.2.0"
  bucket_name = var.bucket_name

  log_bucket_id    = "build-${local.account_name}-access-logs"
  data_sensitivity = "low"
  force_destroy    = true
  data_expiry      = "forever-config-only"
  kms_key_policy   = ""
  tags = var.tags
  use_default_encryption = true
}

resource "aws_s3_bucket_policy" "public_read_for_get_bucket_objects" {
  bucket = module.bucket.id
  policy = data.aws_iam_policy_document.public_read_for_get_bucket_objects.json
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = var.bucket_name
}

data "aws_iam_policy_document" "public_read_for_get_bucket_objects" {
  version = "2012-10-17"
  statement {
    sid    = "PublicReadForGetBucketObjects"
    effect = "Allow"
    principals {
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
      type        = "AWS"
    }
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${module.bucket.arn}/*"
    ]
  }
  statement {
    sid = "DenyInsecureTransport"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = ["s3:*"]
    resources = [
                "${module.bucket.arn}/*",
                "${module.bucket.arn}"
            ]
    condition {
              test = "Bool"
              variable = "aws:SecureTransport"
              values = ["false"]
            }
        }
}