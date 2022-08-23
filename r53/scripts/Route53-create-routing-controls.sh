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

REGION=us-west-2
STACK_NAME=Route53ARC-RoutingControl
aws --region $REGION cloudformation create-stack               \
    --template-body file://../cloudformation/Route53-ARC-routing-control.yaml  \
    --stack-name $STACK_NAME                                   \
    --disable-rollback \
    --parameters ParameterKey=Region1,ParameterValue=$region1 \
                 ParameterKey=Region2,ParameterValue=$region2 
