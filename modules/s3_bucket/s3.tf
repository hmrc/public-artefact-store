resource "aws_s3_bucket_public_access_block" "website" {
  bucket                  = var.bucket_name
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "website" {
  bucket = var.bucket_name
  acl    = "private"

  tags = var.tags

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = false
    noncurrent_version_expiration {
      days = 90
    }
  }
}

resource "aws_s3_bucket_policy" "public_read_for_get_bucket_objects" {
  bucket = aws_s3_bucket.website.bucket
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
      "${aws_s3_bucket.website.arn}/*"
    ]
  }
}