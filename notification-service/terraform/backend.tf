terraform {
  backend "s3" {

    #This will allow you as an owner to download and view your state file.
    acl = "private"

    #---------------------------
    # NEVER CHANGE THESE VALUES
    #---------------------------
    #This is the bucket where to store your state file.
    bucket = "sftp-terraform-state-bucket"

    #This ensures the state file is stored encrypted at rest in S3.
    encrypt = true

    #This is the region of your S3 Bucket.
    region = "eu-west-1"

    #---------------------------
    # Configurable Options
    #---------------------------

    #This will be the state file's file name.
    key = "sftp-transfer-s3-bucket-monitor-lambda-state"

    #This will be used as a folder in which to store your state file.
    workspace_key_prefix = "sftp-s3-transfer-monitor-lambda"
  }
}
