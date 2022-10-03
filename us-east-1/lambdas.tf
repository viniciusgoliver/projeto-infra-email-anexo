# Lambdas

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "fn_lambdas_logging" {
  name        = "fn-lambdas-logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

# fn-service-attatch

data "archive_file" "fn_service_attatch_file" {
  type        = "zip"
  output_path = "/tmp/service-attatch.zip"

  source {
    content  = <<EOF
exports.handler = async (event, context) => {
  return {
    statusCode: 200,
    body: JSON.stringify('init lambda Service Attatch')
  }
}
EOF
    filename = "fn-service-attatch.js"
  }
}

variable "fn_service_attatch" {
  default = "fn-service-attatch"
}

resource "aws_lambda_function" "fn_service_attatch" {
  filename      = data.archive_file.fn_service_attatch_file.output_path
  function_name = var.fn_service_attatch
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "fn-service-attatch.handler"
  timeout       = 60

  runtime = "nodejs14.x"

  environment {
    variables = {
      env    = "development"      
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.fn_service_attatch_logs,
    aws_cloudwatch_log_group.fn_service_attatch_log_group,
  ]
}

resource "aws_cloudwatch_log_group" "fn_service_attatch_log_group" {
  name              = "/aws/lambda/${var.fn_service_attatch_name}"
  retention_in_days = 5
}

resource "aws_iam_role_policy_attachment" "fn_service_attatch_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.fn_lambdas_logging.arn
}

resource "aws_iam_policy" "fn_service_attatch_policies" {
  name        = "fn_service_attatch_policies"
  path        = "/"
  description = "IAM policies for Service Attatch lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "fn_service_attatch_policies_attachment" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.fn_service_attatch_policies.arn
}


# fn-service-consumer

resource "aws_iam_role_policy_attachment" "fn_service_consumer_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.fn_lambdas_logging.arn
}

resource "aws_iam_policy" "fn_service_consumer_policies" {
  name        = "fn_service_consumer_policies"
  path        = "/"
  description = "IAM policies for Service Concumer lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:*",
        "S3:GetObject",
        "S3:PutObject"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "fn_service_consumer_policies_attachment" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.fn_service_consumer_policies.arn
}

data "archive_file" "fn_service_consumer_file" {
  type        = "zip"
  output_path = "/tmp/service_consumer.zip"

  source {
    content  = <<EOF
exports.handler = async (event, context) => {
  return {
    statusCode: 200,
    body: JSON.stringify('init lambda Service Consumer')
  }
}
EOF
    filename = "fn-service-consumer.js"
  }
}

variable "fn_service_consumer_name" {
  default = "fn-service-cionsumer"
}

resource "aws_lambda_function" "fn_service_consumer" {
  filename      = data.archive_file.fn_service_consumer_file.output_path
  function_name = var.fn_service_consumer_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "fn-service-consumer.handler"
  timeout       = 60

  runtime = "nodejs14.x"

  environment {
    variables = {
      env    = "development"      
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.fn_service_consumer_logs,
    aws_cloudwatch_log_group.fn_service_consumer_log_group,
  ]
}

resource "aws_cloudwatch_log_group" "fn_service_consumer_log_group" {
  name              = "/aws/lambda/${var.fn_service_consumer_name}"
  retention_in_days = 5
}

