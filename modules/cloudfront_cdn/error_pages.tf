resource "aws_s3_bucket_object" "error_file_404" {
  bucket = data.aws_s3_bucket.website.bucket
  key    = "404.html"

  content      = "This resource does not exist or has been removed"
  content_type = "text/html"
}
