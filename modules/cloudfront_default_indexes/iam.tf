resource "aws_iam_role" "lambda_role" {
  name               = var.name_prefix
  assume_role_policy = data.aws_iam_policy_document.main_assume_role.json
  tags               = var.tags
}

data "aws_iam_policy_document" "main_assume_role" {
  statement {
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "allow_logging" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:log-group:/aws/lambda/${aws_lambda_function.lambda_edge.function_name}:*"
    ]
  }
}

resource "aws_iam_policy" "allow_logging" {
  name = "${var.name_prefix}-allow-logging"
  policy = data.aws_iam_policy_document.allow_logging.json
}

resource "aws_iam_role_policy_attachment" "allow_logging" {
  policy_arn = aws_iam_policy.allow_logging.arn
  role = aws_iam_role.lambda_role.name
}


