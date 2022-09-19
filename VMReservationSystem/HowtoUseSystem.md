This repository contains the solution codebase for the problem statement where we are creating a restapi based interface that will help the users to allocate and deallocate
VMs from a pool of machines.

# Summary
AWS This Codebase contains AWS API Gateway, Lambda, IAM and Cloudwatch services. This system can be made production grade with the use of other persistent services such as 
AWs RDS database for storing the key informations such as user details, VM details etc. For simplicity I have used lambda function only which is using pre defined objects(for mocking VMs).

# Repo Structure
The main level contains the following folder and file structure:
- **lambda** <------ Folder containing lambda.py file which contains code to process the user inputs.
- **terraform/** <-- Folder containing terraform resources (configuration files). 
- **README.md** <--- The file that is auto generated using terraform-docs which contains the details of the resources created by terraform.
- **.gitignore** <-- Tells local git to ignore files so they do not get committed and tracked to codebase(Meant for protecting sensitive files such as terraform state to be accidently commited to git or any public location).

Within terraform folder the following files exist.
- **terraform/**
  -  **backend.tf** <-- Defines where to store your terraform state file
  -  **main.tf** <-- Contains the terraform resources to create given services. (Here we have used one file for creating all the services but this can be separated for each service and terraform will detect the resources without any issues.)
  -  **terraform.tfvars** <-- Contains variables common across all environments. This is the default variable file for terraform.
  -  **variables.tf** <-- Contains global variables referenced in main.tf, example: variable "Owner" {}
  

## Order of Creating Infrastructure
 - Backend.tf File has menioned a bucket name that needs to be created first which holds the state file for terraform, so this bucket needs to be created separately and it needs to exist before running terraform. 
 - The lambda folder contains lambda.py file which need to be compressed and stored at the same location. We can use any tool or zip command to compress the lambda folder.
 - Run terraform init from the terraform folder which will initialize terraform for us. 
 - Run terraform plan and check the resources that are getting created from the plan.
 - Finally, run terraform apply command to start creating the resources and once it finished creating successfully it will show how many resources are created and if not then error message will appear.

# IAM setup/dependencies and Security assumptions inside the solution.
The roles and policies are also part of terraform configuration and they are automated as well. The principal of least priviledge is followed while giving out permissions to the API and Lambda Services.
Also S3 bucket that stores the state file need not be publicly exposed and must be secured suing proper policies and permissions. 

## How to request VM and release VM
- For requesting VM, we need to do a POST api call to the API (https://mydemoapi.execute-api.us-east-1.amazonaws.com/resources/getvm) with parameter userid and value. If not already allocated, the response will give the necessary details of the VM you can using along with login information such as ip and keys. If you already have allocated VM then response will contain error that you cannot be allocated with new VM as you already been allocated. 
- For releasing VM, we need to do a POST api call to the same API but different method name (https://mydemoapi.execute-api.us-east-1.amazonaws.com/resources/releasevm) with parameter userid and value. This will check the userid and will release the VM from your id and will be made available for anyone to use after doing some pre-checks.
- If no VMs are available in the pool then an error message will apprear in the API response.

## Further Improvements 
 - Although this solution does not use DNS mapping as I don't own any domain name but it is critical component when we are delaing with multiple users in multiple regions and we can utilize to provide a user friendly api name to our resources.
 - We have not used any RDS/persistent storage services but we can further make this system rock-solid using services such as RDS or EFS to store the details of VMs, users as well as other metadata. This will help the system management in case of failures.
