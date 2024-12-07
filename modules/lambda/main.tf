data "archive_file" "lambda" {
  type        = "zip"
  source_file = "modules/lambda/cloudfront_origin_request.py"
  output_path = ".modules/lambda/cloudfront_origin_request.zip"
}

resource "aws_lambda_function" "origin_request" {
  count    = var.create_lambda_at_edge ? 1 : 0
  provider = aws.useast1
  # If the file is not in the current working directory you will need to include a path.module in the filename.
  filename         = "modules/lambda/cloudfront_origin_request.zip"
  function_name    = "cloudfront_origin_request"
  description      = "Process the origin request"
  role             = aws_iam_role.cloudfront_viewer_request[0].arn
  handler          = "cloudfront_origin_request.lambda_handler"
  timeout          = 3
  source_code_hash = data.archive_file.lambda.output_base64sha256
  publish          = true # Whether to publish creation/change as new Lambda Function Version.
  runtime          = "python3.12"
}

resource "aws_iam_role" "cloudfront_viewer_request" {
  count = var.create_lambda_at_edge ? 1 : 0
  name  = "cloudfront_viewer_request_lambda_IAM_role"
  path  = "/"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17"
    "Statement" : [
      {
        "Action" : "sts:AssumeRole"
        "Effect" : "Allow",
        "Sid" : ""
        "Principal" : {
          "Service" : [
            "lambda.amazonaws.com",
            "edgelambda.amazonaws.com"
          ]
        }
      },
    ]
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
}

provider "aws" {
  alias  = "useast1"
  region = "us-east-1"

  # default_tags {
  #   tags = local.default_tags
  # }
}
