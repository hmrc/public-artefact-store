variable "bucket_regional_domain_name" {
  type = string
}
variable "bucket_name" {
  type = string
}
variable "domain_name" {
  type = string
}
variable "cloudfront_access_identity_path" {
  type = string
}
variable "acm_certificate_arn" {
  type = string
}
variable "origin_request_trigger_lambda_arn" {
  type = string
}
variable "name_prefix" {
  type = string
}
variable "tags" {
  type = map(string)
}