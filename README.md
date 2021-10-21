This repository contains the solution codebase for the problem statement where we're helping a global financial institution to utilize this solution so that they can use simple SFTP protocol to receive files for their datalake on AWS from mutiple agencies. 

### Disclaimer:
 - This Codebase contains AWS SFTP Transfer service template. It contains a simple example of two users and one S3 bucket. For safety concerns thsi sftp server is not internet exposed and should be accessed via VPC, assuming customer agencies has access to customer VPC so that they can upload data without going to the public internet. Careful consideration has been made regarding security/control requirements before implementation.  The general recommendation is that one team will want to use one bucket per user. You will need to further place controls on that bucket and permissions which the user requires.

# sftp-transfer-internal (Getting Started Documentation)
 - https://aws.amazon.com/sftp/
 - https://docs.aws.amazon.com/transfer/latest/userguide/what-is-aws-transfer-for-sftp.html

# Summary
AWS Transfer for SFTP (AWS SFTP) is a fully managed AWS service that enables you to transfer files over Secure File Transfer Protocol (SFTP), into and out of Amazon Simple Storage Service (Amazon S3) storage. This solution configures an SFTP Service and an s3 bucket along with two users for 2 agencies. For monitoring and alerting purposes I am using event driven architetcure which uses AWS Lambda, AWS SES and AWS Event Bridge to alert DataOps Team.

## Creating Private Key
 - I am not intented to provide a Private Key for this Solution, you will need to generate and apply your own. The reason for this is it is not okay to expose private keys, and it is not a good idea to have a solution that does so, it sets a dangerous precedent even if there is a disclaimer against this. Please keep your Private Keys secure and appropriately managed. One way to use these pivate keys into this solution is to use AWS Secrets Manager to store sensitive information and keys which can be used dynamically while deploying this solution. Also we can use CI specific parameterized services which are present in CI tools as well if we have automated process to deploy the infrastructure code.
  - To Generate your own Private Key, a quick way to do so in Windows is by using GitBash: https://help.github.com/en/enterprise/2.17/user/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
  - Right now the Property file has a placeholder value to show where the public side of the rsa string would go: **sftp_user_key** 

## Order of Creating Infrastructure
 - Terraform resource **aws_transfer_user** has an optional field **home_directory** that places a user into a specific location on a specified s3 bucket. To do this, the S3 bucket must be created first.
 - Create Transfer Service after S3 bucket is created and confirmed discoverable in account it was created in.
 - Monitoring is a completely different aspect and it can be deployed independently. 

## DNS 
 - Although this solution does not use DNS mapping as I don't own any domain name but it is critical component when we are delaing with multiple clients in multiple regions and we can utilize latency based routing mechanism present in Route53 to redirect upload request to nearest storage location using SFTP servers and S3 deployed in the nearest region in AWS. Later we can do cross replication from all the buckets to a centralized S3 location called master s3 bucket.
 - Here is a sneak peak into the architecture diagram that I am trying to describe above (https://aws.amazon.com/blogs/storage/minimize-network-latency-with-your-aws-transfer-for-sftp-servers/)

# Repo Structure
The main level contains the following folder and file structure:
- **notification-service** <---- Separate solution for monitoring the daily uploads of files to s3 and sending out alerts. 
- **transfer/** <-- folder containing sftp resources. 
- **s3/** <-- folder containing s3 resources.
- **README.md** <-- You are HERE
- **.gitignore** <= tells local git to ignore files so they do not get committed and tracked to codebase

Within each folder (s3, transfer) is the following to create the given resources of that folder.
- **terraform/**
  -  **backend.tf** <-- Defines where to put your state file
  -  **main.tf** <-- Contains the terraform resources to create given service
  -  **terraform.tfvars** <-- Contains variables common across all environments
  -  **variables.tf** <-- Contains global variables referenced in main.tf, example: variable "Owner" {}
  
# IAM setup/dependencies and Security assumptions inside the solution.
The roles and policies are also part of terraform configuration and they are automated as well. The principal of least priviledge is followed while giving out permissions to the sftp server as well as sftp users.
Also special care has been taken to secure s3 bucket from being exposed publicily as the buckets contains sensitive PII informationa dn must not be exposed.

# Helpful Links
- [Terraform S3 Bucket](https://www.terraform.io/docs/providers/aws/r/s3_bucket.html)
- [aws_transfer_server](https://www.terraform.io/docs/providers/aws/r/transfer_server.html)
- [aws_transfer_user](https://www.terraform.io/docs/providers/aws/r/transfer_user.html)
- [aws_transfer_ssh_key](https://www.terraform.io/docs/providers/aws/r/transfer_ssh_key.html)

