data "aws_iam_policy_document" "kms_policy" {
  statement {
    sid    = "AllowDDosResponseTeamDecrypt"
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "drt.shield.amazonaws.com",
      ]
    }

    actions = [
      "kms:Decrypt",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowDecrypt"
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        aws_iam_role.firehose_role.arn,
      ]
    }

    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*",
    ]

    resources = ["*"]
  }

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
}

resource "aws_kms_key" "waf_acl" {
  description             = "${var.name_prefix}-web-acl-log-key"
  deletion_window_in_days = 7
  policy                  = data.aws_iam_policy_document.kms_policy.json
  tags                    = var.tags
}