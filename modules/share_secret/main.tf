locals {
  cross_account        = length(var.allowed_account_ids) == 0 ? false : true
  allowed_account_arns = formatlist("arn:aws:iam::%s:root", var.allowed_account_ids)
}

resource "aws_secretsmanager_secret" "secret" {
  name       = var.secret_name
  kms_key_id = local.cross_account ? aws_kms_key.secret_manager[0].arn : null
  tags       = var.tags
  policy     = local.cross_account ? data.aws_iam_policy_document.secret_policy[0].json : null

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
  policy                  = data.aws_iam_policy_document.kms_policy[0].json
  tags                    = var.tags
}

data "aws_caller_identity" "current" {}


data "aws_iam_policy_document" "kms_policy" {
  count   = local.cross_account ? 1 : 0
  version = "2012-10-17"
  statement {
    sid    = "KeyManagement"
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
  statement {
    sid    = "AllowDecrypt"
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
