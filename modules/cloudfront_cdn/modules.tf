module "cloudfront-logs" {
  source      = "fmasuhr/cloudfront-logs/aws"
  version     = "1.6.2"
  bucket_name = "${local.aws_resource_safe_domain_name}-access-logs"
  name        = "${local.aws_resource_safe_domain_name}-access-logs"
  retention   = 365
  tags        = var.tags
}

resource "aws_kms_key" "cloudfront_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  policy                  = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "key-default-1",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow CloudFront to use the key to deliver logs",
            "Effect": "Allow",
            "Principal": {
                "Service": "delivery.logs.amazonaws.com"
            },
            "Action": [
                "kms:GenerateDataKey*",
                "kms:Decrypt"
            ],
            "Resource": "*"
        },
        {
            "Sid": "kmsdecrypt",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${module.cloudfront-logs.this_lambda_function.role}"
            },
            "Action": "kms:Decrypt",
            "Resource": "*"
        }
    ]
  }
  EOF
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = module.cloudfront-logs.this_s3_bucket.bucket
  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.cloudfront_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
