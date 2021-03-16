variable "domain_name" {
  type = string
}
variable "bucket_regional_domain_name" {
  type = string
}
variable "bucket_name" {
  type = string
}
variable "cloudfront_access_identity_path" {
  type = string
}
variable "name_prefix" {
  type = string
}
variable "tags" {
  type = map(string)
}