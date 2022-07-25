module "bucket" {
  source  = "git@github.com:hmrc/terraform-aws-s3-bucket-standard?ref=1.3.0"

  bucket_name   = var.bucket_name
  force_destroy = false

  list_roles = [
    aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn,
    local.build_and_deploy_api_lambda_role,
    "arn:aws:iam::893174414079:role/RoleBuildEngineer",
    "arn:aws:iam::893174414079:role/MDTPBuildCodeBuild",
    "arn:aws:iam::565237821078:role/RoleBuildEngineer",
    "arn:aws:iam::565237821078:role/MDTPBuildCodeBuild",
  ]
  read_roles = [
    aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn,
    local.build_and_deploy_api_lambda_role,
    "arn:aws:iam::893174414079:role/RoleBuildEngineer",
    "arn:aws:iam::893174414079:role/MDTPBuildCodeBuild",
    "arn:aws:iam::565237821078:role/RoleBuildEngineer",
    "arn:aws:iam::565237821078:role/MDTPBuildCodeBuild",
  ]
  write_roles = [
    local.build_and_deploy_api_lambda_role,
    "arn:aws:iam::893174414079:role/RoleBuildEngineer",
    "arn:aws:iam::893174414079:role/MDTPBuildCodeBuild",
    "arn:aws:iam::565237821078:role/RoleBuildEngineer",
    "arn:aws:iam::565237821078:role/MDTPBuildCodeBuild",
  ]
  admin_roles = [
    "arn:aws:iam::893174414079:role/RoleBuildEngineer",
    "arn:aws:iam::893174414079:role/MDTPBuildCodeBuild",
    "arn:aws:iam::565237821078:role/RoleBuildEngineer",
    "arn:aws:iam::565237821078:role/MDTPBuildCodeBuild",
  ]

  data_expiry      = "forever-config-only"
  data_sensitivity = "low"

  log_bucket_id = "${terraform.workspace == "live" ? "build-live-access-logs" : "build-labs-access-logs"}"
  tags          = var.tags
}
