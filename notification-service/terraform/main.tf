#------------------------------------------------------------
# Cloud Provider (Here we arenusing AWS as a cloud provider)
#------------------------------------------------------------
provider "aws" {
  region = var.region
}

#---------------------
# Data Sources
#---------------------
data "aws_caller_identity" "current" {}

#---------------------
# IAM Resources
#---------------------
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

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_permissions"
  path        = "/"
  description = "IAM policy for s3 and ses permissions to lambda"

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
    },
    {
      "Action": [
        "s3:Get*",
        "s3:List*"
      ],
      "Resource": [ "arn:aws:s3:::sftp-s3-bucket-for-demo", "arn:aws:s3:::sftp-s3-bucket-for-demo/* "],
      "Effect": "Allow"
    },
    {
      "Action": [
        "ses:*"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}


#-----------------------
# Cloudwatch Log Group
#-----------------------
resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 14
}


#-----------------------
# Lambda Function
#-----------------------
resource "aws_lambda_function" "lambda" {

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.log_group,
  ]

  # General settings
  function_name = var.function_name
  description   = "S3 Bucket monitoring for data upload using Lambda"
  filename      = "../lambda.zip"
  handler       = "lambda/notification.lambda_handler"

  # Run time configuration
  memory_size      = "128"
  timeout          = "100"
  runtime          = "python3.8"
  role             = aws_iam_role.iam_for_lambda.arn
  source_code_hash = filebase64sha256("../lambda.zip")

  tags = {
    Name    = "sftp-transfer-s3-bucket-monitor-lambda"
    Owner   = var.owner
    git_url = var.git_url
  }
}

#-----------------------
# Cloudwatch Event Rule
#-----------------------

resource "aws_cloudwatch_event_rule" "daily" {
  name                = "daily"
  description         = "Fires lambda daily"
  schedule_expression = "cron(55 23 * * ? *)"
}

#--------------------------
# Cloudwatch Event Target
#--------------------------
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily.name
  target_id = "lambda"
  arn       = aws_lambda_function.lambda.arn
}


#-----------------------
# AWS Lambda Permission
#-----------------------
resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily.arn
}


#---------------------
# Output Sources
#---------------------
output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}
