variable "secret_name" {
  type = string
}
variable "secret_value" {
  type = string
}
variable "allowed_account_ids" {
  type    = list(string)
  default = []
}
variable "tags" {
  type    = map(string)
  default = {}
}
variable "override_policy_documents" {
  type    = list(string)
  description = "List of IAM policy documents to merge. Overrides statements with the same sid."
  default = null
}
