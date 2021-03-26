provider "aws" {
  alias  = "us_east_1"
}

resource "aws_lambda_function" "lambda_edge" {
  provider = aws.us_east_1

  function_name = var.name_prefix
  runtime = "nodejs14.x"
	publish  = true 
}

