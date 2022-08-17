output "bucket_name" {
  value = module.bucket.id
}
output "cloudfront_access_identity_path" {
  value = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
}
output "bucket_regional_domain_name" {
  value = module.bucket.bucket_regional_domain_name
}