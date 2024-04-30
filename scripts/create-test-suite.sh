#!/usr/bin/env bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

templateprefix=cfn
templatebucket=$1
secondbucket=$2
stackname=$3
region=$4
otherregion=$5
SCRIPTDIR=`dirname $0`
if [ "$templatebucket" == "" ]
then
    echo "Usage: $0 <template bucket> <bucket in second region> <stack name> <region> <other region> <--update>"
    exit 1
fi
if [ "$secondbucket" == "" ]
then
    echo "Usage: $0 <template bucket> <bucket in second region> <stack name> <region> <other region> <--update>"
    exit 1
fi
if [ "$stackname" == "" ]
then
    echo "Usage: $0 <template bucket> <bucket in second region> <stack name> <region> <other region> <--update>"
    exit 1
fi
if [ "$region" == "" ]
then
    echo "Usage: $0 <template bucket> <bucket in second region> <stack name> <region> <other region> <--update>"
    exit 1
fi
if [ "$otherregion" == "" ]
then
    echo "Usage: $0 <template bucket> <bucket in second region> <stack name> <region> <other region> <--update>"
    exit 1
fi
UPDATE=${6:-""}    
CFN_CMD="create-stack"
if [ "$UPDATE" == "--update" ]
then
    CFN_CMD="update-stack"
    echo "Updating stack"
fi

# Check if we need to append region to S3 URL
TEMPLATE_URL=https://s3.amazonaws.com/$templatebucket/$templateprefix/test-suite.yaml
if [ "$region" != "us-east-1" ]
then
    TEMPLATE_URL=https://s3-$region.amazonaws.com/$templatebucket/$templateprefix/test-suite.yaml
fi

echo "Uploading CFN scripts"
aws s3 sync $SCRIPTDIR/../cfn s3://$templatebucket/$templateprefix

aws cloudformation $CFN_CMD --stack-name $stackname \
    --template-url $TEMPLATE_URL \
    --tags Key=Project,Value=resilientdynamo \
    --disable-rollback \
    --parameters \
    ParameterKey=Bucket,ParameterValue=$templatebucket \
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
    --region $region

aws cloudformation $CFN_CMD --stack-name $stackname \
    --template-url $TEMPLATE_URL \
    --tags Key=Project,Value=resilientdynamo \
    --disable-rollback \
    --parameters \
    ParameterKey=Bucket,ParameterValue=$secondbucket \
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
    --region $otherregion
