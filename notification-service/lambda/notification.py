#!/usr/bin/env python
import boto3
from datetime import date

# ----------------------------------------------------------
# Lambda Handler Function
# ----------------------------------------------------------


def lambda_handler(event, context):
    bucket_name = "sftp-s3-bucket-for-demo"
    subfolders = ["user1", "user2", "user3"]
    for folder in subfolders:
        list_of_users = get_list_of_users_not_uploaded_data(
            bucket_name, folder)
    print(list_of_users)
    response = send_email(list_of_users)
    return response


# -----------------------------------------------------------------------
# Function to get list of customers/users not uploaded daily data in S3
# -----------------------------------------------------------------------

def get_list_of_users_not_uploaded_data(bucket_name, folder):
    s3 = boto3.client('s3')
    paginator = s3.get_paginator("list_objects_v2")
    page_iterator = paginator.paginate(Bucket=bucket_name, Prefix=folder)
    latest = None
    list_of_users = []
    for page in page_iterator:
        if "Contents" in page:
            latest2 = max(page['Contents'], key=lambda x: x['LastModified'])
            if latest is None or latest2['LastModified'] > latest['LastModified']:
                latest = latest2
    if (latest is None or latest['LastModified'].date() < date.today()):
        list_of_users.append(folder)

    return list_of_users


# -----------------------------------------------------------
# Function to send email alert  notification to DataOps Team
# -----------------------------------------------------------

def send_email(list_of_users):
    ses_client = boto3.client("ses", region_name="eu-west-1")
    response = ses_client.send_email(
        Source='nileshchoudhary62@yahoo.com',
        Destination={
            'ToAddresses': [
                "nileshchoudhary62@yahoo.com"
            ]
        },
        Message={
            'Subject': {
                'Data': 'Attention Required regarding DataLake Upload',
                'Charset': 'UTF-8'
            },
            'Body': {
                'Html': {
                    'Data': '<p>Greetings!!! </p> <p>DataOps team have noticed that following customers have not uploaded today\'s data files to the datalake. Please connect with the customers to find out the cause.<p>{}</p></p>Thank you for your cooperation.</p> <p> </p> <p> Regards, </p> <p> </p> <p>DataOps Team</p>'.format(list_of_users),
                    'Charset': 'UTF-8'
                }
            }
        }
    )
    return response
