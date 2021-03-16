output "bucket_name" {
  value = aws_s3_bucket.website.bucket
}
output "cloudfront_access_identity_path" {
  value = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
}
output "bucket_regional_domain_name" {
  value = aws_s3_bucket.website.bucket_regional_domain_name
}