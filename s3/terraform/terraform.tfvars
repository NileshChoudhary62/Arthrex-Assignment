#---------------------------------------------------------------------------------------------------------
# This is called the variable file from where we pass the variable values to the main.tf terraform file.
# Terraform pickups this file as by default for variables.
#---------------------------------------------------------------------------------------------------------
region         = "eu-west-1"
s3_bucket_name = "sftp-s3-bucket-for-demo"
sftp_user      = "user1"
sftp_user2     = "user2"
git_url        = "https://github.com/NileshChoudhary62/DataChef-Assignment.git"
owner          = "NileshChoudhary62"
