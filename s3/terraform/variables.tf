#-----------------------
# Variables
#-----------------------
variable "git_url" {}
variable "region" {}
variable "s3_bucket_name" {}
variable "owner" {
  default = "Nilesh"
}
variable "sftp_user" {}
variable "sftp_user2" {}

# Helps to retrieve and restore every version stored in s3 bucket.
variable "versioning" {
  default = true
}

