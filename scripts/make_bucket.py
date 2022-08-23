# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

import boto3    
import sys
import argparse
import json

parser = argparse.ArgumentParser(description='Create S3 Bucket')
parser.add_argument('--name', help='Bucket name', required=True)
parser.add_argument('--region', help='Bucket region', required=True)
parser.add_argument('--version', default='yes', choices=['yes','no'], help='Bucket versioning enabled (yes|no)')
args = parser.parse_args()
print(f"Creating bucket {args.name} in region {args.region} with versioning set to {args.version}")

s3 = boto3.client('s3', region_name=args.region)

if args.region == 'us-east-1':
    response = s3.create_bucket(
        ACL='private',
        Bucket=args.name,
    )
else:
    response = s3.create_bucket(
        ACL='private',
        Bucket=args.name,
        CreateBucketConfiguration={
            'LocationConstraint': args.region
        }
    )
print(json.dumps(response))
response = s3.put_bucket_encryption(
    Bucket=args.name,
    ServerSideEncryptionConfiguration={
        'Rules': [
            {
                'ApplyServerSideEncryptionByDefault': {
                    'SSEAlgorithm': 'AES256'
                }
            }
        ]
    }
)
print(json.dumps(response))
if args.version == 'yes':
    response = s3.put_bucket_versioning(
        Bucket=args.name,
        VersioningConfiguration={
            'MFADelete': 'Disabled',
            'Status': 'Enabled'
        }
    )
    print(json.dumps(response))
