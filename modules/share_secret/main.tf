terraform {
  required_version = ">= 0.15.1"
}

locals {
  cross_account        = length(var.allowed_account_ids) > 0 ? true : false
  allowed_account_arns = formatlist("arn:aws:iam::%s:root", var.allowed_account_ids)
  cross_account_policy_document = local.cross_account ? one(data.aws_iam_policy_document.cross_account).json : ""
}

data "aws_caller_identity" "current" {}

resource "aws_secretsmanager_secret" "secret" {
  name       = var.secret_name
  kms_key_id = local.cross_account ? one(aws_kms_key.secret_manager).arn : null
  tags       = var.tags
  policy     = local.cross_account ? one(data.aws_iam_policy_document.secret_policy).json : null

  recovery_window_in_days = 0 //this allows recreation of the secret right away
}

data "aws_iam_policy_document" "secret_policy" {
  count   = local.cross_account ? 1 : 0
  version = "2012-10-17"
  statement {
    sid    = "ReadSecret"
    effect = "Allow"
    principals {
      identifiers = local.allowed_account_arns
      type        = "AWS"
    }
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_secretsmanager_secret_version" "secret" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = var.secret_value
}

resource "aws_kms_key" "secret_manager" {
  count                   = local.cross_account ? 1 : 0
  description             = "secrets manager ${var.secret_name}"
  deletion_window_in_days = 7
  policy                  = data.aws_iam_policy_document.kms_policy.json
  tags                    = var.tags
}

resource "aws_kms_alias" "secret_manager" {
  count         = local.cross_account ? 1 : 0
  name          = replace("alias${var.secret_name}", ".", "-")
  target_key_id = aws_kms_key.secret_manager[0].key_id
}

data "aws_iam_policy_document" "kms_policy" {
  source_policy_documents = [
    data.aws_iam_policy_document.kms_policy_default.json,
    local.cross_account_policy_document,
  ]
  override_policy_documents = var.override_policy_documents
}

data "aws_iam_policy_document" "kms_policy_default" {
  version = "2012-10-17"
  statement {
    sid    = "AllowAccessForUsers"
    effect = "Allow"
    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
      type        = "AWS"
    }
    actions = [
      "kms:*"
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "cross_account" {
  count   = local.cross_account ? 1 : 0
  statement {
    sid    = "AllowCrossAccountDecrypt"
    effect = "Allow"
    principals {
      identifiers = local.allowed_account_arns
      type        = "AWS"
    }
    actions = [
      "kms:Decrypt"
    ]
    resources = [
      "*"
    ]
  }
}
