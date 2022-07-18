locals {
  build_and_deploy_api_lambda_role = "${terraform.workspace == "live" ? "arn:aws:iam::565237821078:role/mdtp-live-build-and-deploy-lambda-role" : "arn:aws:iam::893174414079:role/mdtp-lab03-build-and-deploy-lambda-role"}"
}
