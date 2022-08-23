#!/usr/bin/env bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0


APP_STACK=$1

if [ "$APP_STACK" == "" ]
then
    echo "Usage: $0 <application stack name>"
    exit 1
fi

region1=`aws cloudformation describe-stacks --stack-name $APP_STACK | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="FirstRegion").OutputValue'`
region2=`aws cloudformation describe-stacks --stack-name $APP_STACK | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="OtherRegion").OutputValue'`
ctbl=`aws cloudformation describe-stacks --stack-name $APP_STACK | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="CustomerTableName").OutputValue'`
otbl=`aws cloudformation describe-stacks --stack-name $APP_STACK | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="OrderTableName").OutputValue'`
ptbl=`aws cloudformation describe-stacks --stack-name $APP_STACK | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="ProductTableName").OutputValue'`
acct=`aws sts get-caller-identity --query "Account" --output text`
carn="arn:aws:dynamodb:$region1:$acct:table/$ctbl"
parn="arn:aws:dynamodb:$region1:$acct:table/$ptbl"
oarn="arn:aws:dynamodb:$region1:$acct:table/$otbl"
apiid1=`aws cloudformation describe-stacks --stack-name $APP_STACK | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="ApiId").OutputValue'`
s1arn="arn:aws:apigateway:$region1:$acct:/restapis/$apiid1/stages/test"
apiid2=`aws cloudformation describe-stacks --stack-name $APP_STACK --region $region2 | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="ApiId").OutputValue'`
s2arn="arn:aws:apigateway:$region2:$acct:/restapis/$apiid2/stages/test"
readfn1=`aws cloudformation describe-stacks --stack-name $APP_STACK | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="ReadFnArn").OutputValue'`
writefn1=`aws cloudformation describe-stacks --stack-name $APP_STACK | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="WriteFnArn").OutputValue'`
readfn2=`aws cloudformation describe-stacks --stack-name $APP_STACK --region $region2 | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="ReadFnArn").OutputValue'`
writefn2=`aws cloudformation describe-stacks --stack-name $APP_STACK --region $region2 | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="WriteFnArn").OutputValue'`

UPDATE=${2:-""}    
CFN_CMD="create-stack"
if [ "$UPDATE" == "--update" ]
then
    CFN_CMD="update-stack"
    echo "Updating stack"
fi
REGION=us-west-2
STACK_NAME=Route53ARC-ReadinessCheck
aws --region $REGION cloudformation $CFN_CMD \
    --template-body file://../cloudformation/Route53-ARC-readiness-check.yaml  \
    --stack-name $STACK_NAME                                   \
    --disable-rollback \
    --parameters ParameterKey=Region1,ParameterValue=$region1 \
                 ParameterKey=Region2,ParameterValue=$region2 \
                 ParameterKey=Stage1,ParameterValue=$s1arn \
                 ParameterKey=Stage2,ParameterValue=$s2arn \
                 ParameterKey=FnRead1,ParameterValue=$readfn1 \
                 ParameterKey=FnRead2,ParameterValue=$readfn2 \
                 ParameterKey=FnWrite1,ParameterValue=$writefn1 \
                 ParameterKey=FnWrite2,ParameterValue=$writefn2 \
                 ParameterKey=DynamoDBTableProduct,ParameterValue=$parn \
                 ParameterKey=DynamoDBTableOrder,ParameterValue=$oarn \
                 ParameterKey=DynamoDBTableCustomer,ParameterValue=$carn 
