#!/usr/bin/env python
import json

# ----------------------------------------------------------
# Variables for this lambda function defined
# ----------------------------------------------------------

GET_NEW_VM_RESOURCE = "/getvm"
RELEASE_VM = "/releasevm"
userList = {}
vm_details_list = {
    'InstanceId1': {
        'IpAddress': '44.193.201.94',
        'KeyName': 'defaultkeypair'
    },
    'InstanceId2': {
        'IpAddress': '44.193.201.95',
        'KeyName': 'defaultkeypair'
    },
    'InstanceId3': {
        'IpAddress': '44.193.201.96',
        'KeyName': 'defaultkeypair'
    },
    'InstanceId4': {
        'IpAddress': '44.193.201.97',
        'KeyName': 'defaultkeypair'
    }
}

allocated_vm_list = {}

# ----------------------------------------------------------
# Lambda Handler Function
# ----------------------------------------------------------


def lambda_handler(event, context):
    if(event['path'] == GET_NEW_VM_RESOURCE):
        print("*********** Request for New VM ***********")
        userid = event['queryStringParameters']['userid']
        check_user_allocation = check_user(userid)
        result = " "
        if check_user_allocation == "Present":
            result = "User has been already allocated the VM so no new VM can be allocated."
        elif len(vm_details_list) != 0:
            vm_instance = list(vm_details_list.items())[0]
            allocated_vm_list[vm_instance[0]] = vm_instance[1]
            del vm_details_list[vm_instance[0]]
            userList[userid] = vm_instance[0]
            result = f'{"The details of your newly allocated VM are :"} {vm_instance}'
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': result,
            "isBase64Encoded": False
        }

    elif (event['path'] == RELEASE_VM):
        print("************** Release Of VM ********************")
        userid = event['queryStringParameters']['userid']
        vm_instanceid = userList[userid]
        vm_instance_details = allocated_vm_list[vm_instanceid]
        vm_details_list[vm_instanceid] = vm_instance_details
        del allocated_vm_list[vm_instanceid]
        result = f'{"Your instance has been deallocated with instanceId : "} {vm_instanceid}'
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': result,
            "isBase64Encoded": False
        }

    elif(len(vm_details_list) == 0):
        print("************** VM list is empty ********************")
        result = f'{"At this moment no instances are present to be allocated. Please try again after sometime"}'
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': result,
            "isBase64Encoded": False
        }

# -----------------------------------------------------------------------
# Function to check the list of users if they are already allocated VM.
# -----------------------------------------------------------------------


def check_user(userid):
    if userid in userList:
        return "Present"
    else:
        return "Not Present"
