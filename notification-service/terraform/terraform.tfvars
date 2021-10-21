#---------------------------------------------------------------------------------------------------------
# This is called the variable file from where we pass the variable values to the main.tf terraform file.
# Terraform pickups this file as by default for variables.
#---------------------------------------------------------------------------------------------------------
region         = "eu-west-1"
git_url        = "https://github.com/NileshChoudhary62/DataChef-Assignment.git"
owner          = "NileshChoudhary62"
function_name  = "sftp-transfer-s3-bucket-monitor-lambda"