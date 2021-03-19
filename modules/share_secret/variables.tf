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
  type = map(string)
}

