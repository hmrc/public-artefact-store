resource "aws_s3_bucket_policy" "public_read_for_get_bucket_objects" {
  bucket = data.aws_s3_bucket.website.bucket
  policy = data.aws_iam_policy_document.public_read_for_get_bucket_objects.json
}

data "aws_iam_policy_document" "public_read_for_get_bucket_objects" {
  version = "2008-10-17"
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
      "${data.aws_s3_bucket.website.arn}/*"
    ]
  }
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = var.name_prefix
}