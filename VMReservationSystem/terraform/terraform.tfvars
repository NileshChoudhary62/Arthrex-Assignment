#---------------------------------------------------------------------------------------------------------
# This is called the variable file from where we pass the variable values to the main.tf terraform file.
# Terraform picks this file by default for variables.
#---------------------------------------------------------------------------------------------------------
region         = "us-east-1"
function_name  = "vm-resource-lambda-function"
owner          = "Nilesh Choudhary"
api_name       = "vm-resource-api"
log_group_name = "vm-resource-lambda-log-group"
role_name      = "vm-resource-lambda-role"
policy_name    = "vm-resource-lambda-policy"
