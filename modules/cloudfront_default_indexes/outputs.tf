output "lambda_arn" {
  value = aws_lambda_function.lambda_edge.qualified_arn
}
