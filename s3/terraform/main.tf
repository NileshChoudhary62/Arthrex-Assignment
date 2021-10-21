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

#----------------------------
# AWS S3 resource
#----------------------------
resource "aws_s3_bucket" "s3_bucket" {
  acl           = "private" # Acl permissions.
  bucket        = var.s3_bucket_name   # Bucket name to be given in variable.
  force_destroy = true                 # objects should be deleted from the bucket so that the bucket can be destroyed without error.
  # At a minimum, these tags are required.
  tags = {
    git_url = var.git_url
    Name    = var.s3_bucket_name
    Owner   = var.owner
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  versioning {
    enabled = var.versioning
  }
}


#---------------------------------
# AWS S3  Object resources
#---------------------------------

resource "aws_s3_bucket_object" "s3_folder" {
  depends_on             = [aws_s3_bucket.s3_bucket]
  bucket                 = var.s3_bucket_name
  key                    = "${var.sftp_user}/"
  content_type           = "text/plain"
  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_object" "s3_folder2" {
  depends_on             = [aws_s3_bucket.s3_bucket]
  bucket                 = var.s3_bucket_name
  key                    = "${var.sftp_user2}/"
  content_type           = "text/plain"
  server_side_encryption = "AES256"
}


#-----------------------------------------
# AWS S3  Blocking Public Access resource
#-----------------------------------------

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket                  = aws_s3_bucket.s3_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
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

output "bucket_name" {
  value = aws_s3_bucket.s3_bucket.arn
}
