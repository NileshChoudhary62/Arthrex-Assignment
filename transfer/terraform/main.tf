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

#-----------------------------
# AWS Secret Manager Sources
#-----------------------------
data "aws_secretsmanager_secret" "secret1" {
  name = "sftp_user1_key"
}

data "aws_secretsmanager_secret" "secret2" {
  name = "sftp_user2_key"
}

data "aws_secretsmanager_secret_version" "secret1" {
  secret_id = data.aws_secretsmanager_secret.secret1.id
}

data "aws_secretsmanager_secret_version" "secret2" {
  secret_id = data.aws_secretsmanager_secret.secret2.id
}

#---------------------
# AWS VPC Resource
#---------------------

resource "aws_vpc" "main_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Owner   = var.owner
    git_url = var.git_url
  }
}

#-------------------------
# AWS VPC Subnet Resource
#-------------------------
resource "aws_subnet" "main_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Owner   = var.owner
    git_url = var.git_url
  }
}

#--------------------------------
# AWS VPC Security Group Resource
#--------------------------------
resource "aws_security_group" "allow_sftp_traffic" {
  name   = "allow_sftp_traffic"
  vpc_id = aws_vpc.main_vpc.id // not relavent

  ingress {
    description = "SFTP traffic to VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = [aws_vpc.main_vpc.cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name    = "SFTP-Security-Group"
    git_url = var.git_url
  }
}


#---------------------
# IAM Role Resource
#---------------------
resource "aws_iam_role" "sftp_role" {
  name = "sftp-transfer-server-iam-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "transfer.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

#---------------------
# IAM Policy Resource
#---------------------
resource "aws_iam_role_policy" "sftp_policy" {
  name = "sftp-transfer-server-iam-policy"
  role = aws_iam_role.sftp_role.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Sid": "AllowFullAccesstoCloudWatchLogs",
        "Effect": "Allow",
        "Action": [
            "logs:*"
        ],
        "Resource": "*"
        },
        {
			    "Effect": "Allow",
          "Action": [
            "s3:ListBucket",
            "s3:GetBucketLocation"
          ],
         "Resource": [
            "arn:aws:s3:::${var.s3_bucket_name}"
          ]
        },
        {
          "Effect": "Allow",
          "Action": [
            "s3:PutObject",
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:GetObjectACL"
          ],
          "Resource": [
            "arn:aws:s3:::${var.s3_bucket_name}/${var.sftp_user}/*"
        ]
      }
    ]
}
POLICY
}


#---------------------
# SFTP Resource
#---------------------
resource "aws_transfer_server" "sftp_server" {
  identity_provider_type = "SERVICE_MANAGED"
  logging_role           = aws_iam_role.sftp_role.arn
  # endpoint_type          = "PUBLIC"     # If we want our SFTP server to be publicily accessible we can use this setting. 
  # At this point I am assuming the customers are using VPC network for datalake as it is more secure and have less chance to expose PII data to the internet. 

  endpoint_type = "VPC"
  endpoint_details {
    vpc_id             = aws_vpc.main_vpc.id
    subnet_ids         = [aws_subnet.main_subnet.id]
    security_group_ids = [aws_security_group.allow_sftp_traffic.id]
  }

  tags = {
    Name    = var.server_name
    Owner   = var.owner
    git_url = var.git_url
  }
}

#---------------------
# AWS Transfer Users
#---------------------
resource "aws_transfer_user" "user1" {
  server_id           = aws_transfer_server.sftp_server.id
  user_name           = var.sftp_user
  home_directory      = "/sftp-s3-bucket-for-demo/${var.sftp_user}"
  home_directory_type = "LOGICAL"
  home_directory_mappings {
    entry  = "/"
    target = "/sftp-s3-bucket-for-demo/${var.sftp_user}"
  }
  tags = {
    Name    = var.sftp_user
    git_url = var.git_url
  }
}

resource "aws_transfer_user" "user2" {
  server_id           = aws_transfer_server.sftp_server.id
  user_name           = var.sftp_user2
  home_directory      = "/sftp-s3-bucket-for-demo/${var.sftp_user2}"
  home_directory_type = "LOGICAL"
  home_directory_mappings {
    entry  = "/"
    target = "/sftp-s3-bucket-for-demo/${var.sftp_user2}"
  }
  tags = {
    Name    = var.sftp_user2
    git_url = var.git_url
  }
}


#-----------------------------------------
# AWS User SSH Keys for Transfer Service
#-----------------------------------------
resource "aws_transfer_ssh_key" "user1_key" {
  server_id = aws_transfer_server.sftp_server.id
  user_name = aws_transfer_user.user1.user_name
  body      = jsondecode(data.aws_secretsmanager_secret_version.secret1.secret_string)["sftp_user_key"]
}

resource "aws_transfer_ssh_key" "user1_key" {
  server_id = aws_transfer_server.sftp_server.id
  user_name = aws_transfer_user.user2.user_name
  body      = jsondecode(data.aws_secretsmanager_secret_version.secret2.secret_string)["sftp_user_key"]
}


#---------------------
# Output Resources
#---------------------
output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "endpoint" {
  value = aws_transfer_server.sftp_server.endpoint
}


#--------------------------------------------------------------------------------------------------------------
# Optional route53 Resource
# If we want our customers to access server endpoint using standard domain name for e.g. myserver.example.com,
# we can add this resource if we have a domain name.
#--------------------------------------------------------------------------------------------------------------
# resource "aws_route53_zone" "r53_zone" {
#   name = "mydomain.com"
#   tags = {
#     Owner   = var.owner
#     git_url = var.git_url
#   }
# }
# resource "aws_route53_record" "vpce_server" {
#   zone_id = aws_route53_zone.r53_zone.zone_id
#   name    = var.server_name
#   type    = "CNAME"
#   ttl     = "300"
#   records = [aws_transfer_server.sftp_server.endpoint]
# }

