#------------------------------------------------------------
# Cloud Provider (Here we are using AWS as a cloud provider)
#------------------------------------------------------------

provider "aws" {
  region = var.region
}

#---------------------
# Data Sources
#---------------------

data "aws_caller_identity" "current" {}

#------------------------------
# AWS API Gateway API resource
#------------------------------

resource "aws_api_gateway_rest_api" "vm_reservation_api" {
  name        = "vm_reservation_api"
  description = "This is the api that is used to get VMs details for login and the same api can be used to release VMs."
  tags = {
    Name  = var.api_name
    Owner = var.owner
  }
}

#------------------------------
# AWS API Gateway resource
#------------------------------

resource "aws_api_gateway_resource" "vm_reservation_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.vm_reservation_api.id
  parent_id   = aws_api_gateway_rest_api.vm_reservation_api.root_resource_id
  path_part   = "{proxy+}"
}

#---------------------------------------------
# AWS API Gateway GET Method for VMs details.
#---------------------------------------------

resource "aws_api_gateway_method" "vm_reservation_api_method" {
  rest_api_id   = aws_api_gateway_rest_api.vm_reservation_api.id
  resource_id   = aws_api_gateway_resource.vm_reservation_api_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

#--------------------------------------
# AWS API Gateway Integration Resource
#--------------------------------------

resource "aws_api_gateway_integration" "vm_reservation_integration" {
  rest_api_id             = aws_api_gateway_rest_api.vm_reservation_api.id
  resource_id             = aws_api_gateway_resource.vm_reservation_api_resource.id
  http_method             = aws_api_gateway_method.vm_reservation_api_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.vm_reservation_api_lambda_function.invoke_arn
}

#-------------------------------------
# AWS API Gateway Deployment Resource
#-------------------------------------

resource "aws_api_gateway_deployment" "vm_reservation_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.vm_reservation_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.vm_reservation_api.id,
      aws_api_gateway_resource.vm_reservation_api_resource.id,
      aws_api_gateway_method.vm_reservation_api_method.id,
      aws_api_gateway_integration.vm_reservation_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

#--------------------------------------
# AWS API Gateway Stage Resource
#--------------------------------------

resource "aws_api_gateway_stage" "vm_reservation_api_stage" {
  deployment_id = aws_api_gateway_deployment.vm_reservation_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.vm_reservation_api.id
  stage_name    = "resources"
}

#-----------------------
# Cloudwatch Log Group
#-----------------------

resource "aws_cloudwatch_log_group" "vm_reservation_api_lambda_log_group" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 14
  tags = {
    Name  = var.log_group_name
    Owner = var.owner
  }
}

#-----------------------
# Lambda Function
#-----------------------

resource "aws_lambda_function" "vm_reservation_api_lambda_function" {

  depends_on = [
    aws_iam_role.vm_reservation_api_lambda_role,
    aws_iam_policy.vm_reservation_api_lambda_policy,
    aws_iam_role_policy_attachment.vm_reservation_lambda_role_policy_attachment,
    aws_cloudwatch_log_group.vm_reservation_api_lambda_log_group,
  ]

  # General settings
  function_name = var.function_name
  description   = "The lambda function that performs actions based on the api call parameters."
  filename      = "../lambda.zip"
  handler       = "lambda/lambda.lambda_handler"

  # Run time configuration
  memory_size      = "128"
  timeout          = "100"
  runtime          = "python3.8"
  role             = aws_iam_role.vm_reservation_api_lambda_role.arn
  source_code_hash = filebase64sha256("../lambda.zip")

  tags = {
    Name  = var.function_name
    Owner = var.owner
  }
}

#-------------------------------
# AWS Lambda Permission Resource
#-------------------------------

resource "aws_lambda_permission" "vm_reservation_api_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.vm_reservation_api_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.vm_reservation_api.execution_arn}/*/*/*"
}

#-------------------
# IAM Role
#-------------------

resource "aws_iam_role" "vm_reservation_api_lambda_role" {
  name = var.role_name

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

  tags = {
    Name  = var.role_name
    Owner = var.owner
  }

}

#-------------------
# IAM Policy
#-------------------

resource "aws_iam_policy" "vm_reservation_api_lambda_policy" {
  name        = var.policy_name
  path        = "/"
  description = "IAM policy for logs permissions for lambda."

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

  tags = {
    Name  = var.policy_name
    Owner = var.owner
  }

}

#-----------------------
# IAM Policy Attachment
#-----------------------

resource "aws_iam_role_policy_attachment" "vm_reservation_lambda_role_policy_attachment" {
  role       = aws_iam_role.vm_reservation_api_lambda_role.name
  policy_arn = aws_iam_policy.vm_reservation_api_lambda_policy.arn
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

output "api_arn" {
  value = aws_api_gateway_rest_api.vm_reservation_api.arn
}

output "lambda_function" {
  value = aws_lambda_function.vm_reservation_api_lambda_function.arn
}

output "log_group" {
  value = aws_cloudwatch_log_group.vm_reservation_api_lambda_log_group.name
}


