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

  versioning {
    enabled = false
  }
}