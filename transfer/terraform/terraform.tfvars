#---------------------------------------------------------------------------------------------------------
# This is called the variable file from where we pass the variable values to the main.tf terraform file.
# Terraform pickups this file as by default for variables.
#---------------------------------------------------------------------------------------------------------
region          = "eu-west-1"
server_name     = "datalake-sftp-server"
git_url         = "https://github.com/NileshChoudhary62/DataChef-Assignment.git"
s3_bucket_name  = "sftp-s3-bucket"
sftp_user       = "user1"
sftp_user2      = "user2"
owner           = "NileshChoudhary62"