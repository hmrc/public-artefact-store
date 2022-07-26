terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 3.37.0"
      configuration_aliases = [aws.us_east_1]
    }
  }
}

//taken from aws blog post recommend solution
//https://aws.amazon.com/blogs/compute/implementing-default-directory-indexes-in-amazon-s3-backed-amazon-cloudfront-origins-using-lambdaedge/
data "archive_file" "lambda_zip_inline" {
  type        = "zip"
  output_path = "/tmp/${var.name_prefix}_lambda.zip"
  source {
    content  = <<-EOT
    'use strict';
    exports.handler = (event, context, callback) => {

        // Extract the request from the CloudFront event that is sent to Lambda@Edge
        var request = event.Records[0].cf.request;

        // Extract the URI from the request
        var olduri = request.uri;

        // Match any '/' that occurs at the end of a URI. Replace it with a default index
        var newuri = olduri.replace(/\/$/, '\/index.html');

        // Log the URI as received by CloudFront and the new URI to be used to fetch from origin
        console.log("Old URI: " + olduri);
        console.log("New URI: " + newuri);

        // Replace the received URI with the URI that includes the index page
        request.uri = newuri;

        // Return to CloudFront
        return callback(null, request);

    };
EOT
    filename = "main.js"
  }
}

resource "aws_lambda_function" "lambda_edge" {
  provider = aws.us_east_1

  publish       = true
  function_name = var.name_prefix
  role          = aws_iam_role.lambda_role.arn
  filename      = data.archive_file.lambda_zip_inline.output_path
  runtime       = "nodejs12.x"
  handler       = "main.handler"
  tags          = var.tags
}

resource "aws_cloudwatch_log_group" "origin_request_lambda_logs" {
  provider          = aws.us_east_1
  name              = "/aws/lambda/${aws_lambda_function.lambda_edge.function_name}"
  retention_in_days = 7
  tags              = var.tags
}


