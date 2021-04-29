variable "name_prefix" {
  type = string
}
variable "cloudfront_distribution_arn" {
  type = string
}
variable "domain_name" {
  type = string
}
variable "tags" {
  type = map(string)
}