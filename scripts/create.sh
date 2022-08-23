#!/usr/bin/env bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

templateprefix=cfn
stackname=$1
templatebucket=$2
currentregion=$3
primaryregion=$4
otherregion=$5
domainname=$6
SCRIPTDIR=`dirname $0`
if [ "$stackname" == "" ]
then
    echo "Usage: $0 <stack name> <bucket> <current region> <primary region> <other region> <domain name> <--update>"
    exit 1
fi
if [ "$templatebucket" == "" ]
then
    echo "Usage: $0 <stack name> <bucket> <current region> <primary region> <other region> <domain name> <--update>"
    exit 1
fi
if [ "$currentregion" == "" ]
then
    echo "Usage: $0 <stack name> <bucket> <current region> <primary region> <other region> <domain name> <--update>"
    exit 1
fi
if [ "$primaryregion" == "" ]
then
    echo "Usage: $0 <stack name> <bucket> <current region> <primary region> <other region> <domain name> <--update>"
    exit 1
fi
if [ "$otherregion" == "" ]
then
    echo "Usage: $0 <stack name> <bucket> <current region> <primary region> <other region> <domain name> <--update>"
    exit 1
fi
if [ "$domainname" == "" ]
then
    echo "Usage: $0 <stack name> <bucket> <current region> <primary region> <other region> <domain name> <--update>"
    exit 1
fi
UPDATE=${7:-""}    
CFN_CMD="create-stack"
if [ "$UPDATE" == "--update" ]
then
    CFN_CMD="update-stack"
    echo "Updating stack"
fi

# Check if we need to append region to S3 URL
TEMPLATE_URL=https://s3.amazonaws.com/$templatebucket/$templateprefix/template.yaml
if [ "$currentregion" != "us-east-1" ]
then
    TEMPLATE_URL=https://s3-$currentregion.amazonaws.com/$templatebucket/$templateprefix/template.yaml
fi

echo "Uploading CFN scripts"
aws s3 sync $SCRIPTDIR/../cfn s3://$templatebucket/$templateprefix

aws cloudformation $CFN_CMD --stack-name $stackname \
    --template-url $TEMPLATE_URL \
    --tags Key=Project,Value=resilientdynamo \
    --disable-rollback \
    --parameters \
    ParameterKey=DomainName,ParameterValue=$domainname \
    ParameterKey=FirstRegion,ParameterValue=$primaryregion \
    ParameterKey=OtherRegion,ParameterValue=$otherregion \
    ParameterKey=Bucket,ParameterValue=$templatebucket \
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
    --region $currentregion
