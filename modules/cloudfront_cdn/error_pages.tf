resource "aws_s3_object" "error_file_404" {
  bucket = var.bucket_name
  key    = "404.html"

  content      = "This resource does not exist or has been removed"
  content_type = "text/html"
}
