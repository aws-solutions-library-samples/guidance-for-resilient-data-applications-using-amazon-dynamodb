#!/usr/bin/env bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0


REGION=us-west-2
STACK_NAME=Route53-dns-records
APP_STACK=$1
DNS_DOMAIN_NAME=$2
HOSTED_ZONE=$3
REGION1=$4

if [ "$APP_STACK" == "" ] || [ "$DNS_DOMAIN_NAME" == "" ] || [ "$HOSTED_ZONE" == "" ] || [ "$REGION1" == "" ]
then
    echo "Usage: $0 <application stack name> <domain name> <hosted zone>"
    exit 1
fi

ROUTE53_HEALTHCHECKID_CELL1=$(aws --region $REGION cloudformation describe-stacks --stack-name Route53ARC-RoutingControl --query "Stacks[].Outputs[?OutputKey=='HealthCheckIdEast'].OutputValue" --output text)
ROUTE53_HEALTHCHECKID_CELL2=$(aws --region $REGION cloudformation describe-stacks --stack-name Route53ARC-RoutingControl --query "Stacks[].Outputs[?OutputKey=='HealthCheckIdWest'].OutputValue" --output text)


region1=`aws cloudformation describe-stacks --stack-name $APP_STACK --region $REGION1 | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="FirstRegion").OutputValue'`
region2=`aws cloudformation describe-stacks --stack-name $APP_STACK --region $REGION1 | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="OtherRegion").OutputValue'`
rend1=`aws cloudformation describe-stacks --stack-name $APP_STACK --region $REGION1 | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="RegionalDomain").OutputValue'`
rzone1=`aws cloudformation describe-stacks --stack-name $APP_STACK --region $REGION1 | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="RegionalZone").OutputValue'`
rend2=`aws cloudformation describe-stacks --stack-name $APP_STACK --region $region2 | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="RegionalDomain").OutputValue'`
rzone2=`aws cloudformation describe-stacks --stack-name $APP_STACK --region $region2 | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="RegionalZone").OutputValue'`

UPDATE=${4:-""}    
CFN_CMD="create-stack"
if [ "$UPDATE" == "--update" ]
then
    CFN_CMD="update-stack"
    echo "Updating stack"
fi

aws --region $REGION cloudformation $CFN_CMD \
    --template-body file://../cloudformation/Route53-DNS-records.yaml          \
    --stack-name $STACK_NAME                                   \
    --disable-rollback \
    --parameters ParameterKey=Region1,ParameterValue=$region1 \
                 ParameterKey=Region2,ParameterValue=$region2 \
                ParameterKey=DNSHealthcheckId1,ParameterValue=$ROUTE53_HEALTHCHECKID_CELL1 \
                 ParameterKey=DNSHealthcheckId2,ParameterValue=$ROUTE53_HEALTHCHECKID_CELL2 \
                 ParameterKey=DNSDomainName,ParameterValue=$DNS_DOMAIN_NAME \
                 ParameterKey=RegionalEndpoint1,ParameterValue=$rend1 \
                 ParameterKey=RegionalEndpoint2,ParameterValue=$rend2 \
                 ParameterKey=RegionalZone1,ParameterValue=$rzone1 \
                 ParameterKey=RegionalZone2,ParameterValue=$rzone2 \
                 ParameterKey=HostedZoneId,ParameterValue=$HOSTED_ZONE
