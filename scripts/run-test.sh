#!/usr/bin/env bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

STACK=$1
REGION=$2
OTHERREGION=$3
APIURL=$4
ITEMS=$5
INTERVAL=$6
ARCREGION=$7
ARCURL=$8
ARCCTRLA=$9
ARCCTRLB=${10}

if [ "$STACK" == "" ]
then
    echo "Usage: $0 <test stack name> <first region> <second region> <api url> <number of orders> \\"
    echo "<time to wait until switching routing control> <region to use for ARC> \\"
    echo "<endpoint to use for ARC> <first routing control ARN> <second routing control ARN"
    exit 1
fi
if [ "$REGION" == "" ]
then
    echo "Usage: $0 <test stack name> <first region> <second region> <api url> <number of orders> \\"
    echo "<time to wait until switching routing control> <region to use for ARC> \\"
    echo "<endpoint to use for ARC> <first routing control ARN> <second routing control ARN"
    exit 1
fi
if [ "$OTHERREGION" == "" ]
then
    echo "Usage: $0 <test stack name> <first region> <second region> <api url> <number of orders> \\"
    echo "<time to wait until switching routing control> <region to use for ARC> \\"
    echo "<endpoint to use for ARC> <first routing control ARN> <second routing control ARN"
    exit 1
fi
if [ "$APIURL" == "" ]
then
    echo "Usage: $0 <test stack name> <first region> <second region> <api url> <number of orders> \\"
    echo "<time to wait until switching routing control> <region to use for ARC> \\"
    echo "<endpoint to use for ARC> <first routing control ARN> <second routing control ARN"
    exit 1
fi
if [ "$ITEMS" == "" ]
then
    echo "Usage: $0 <test stack name> <first region> <second region> <api url> <number of orders> \\"
    echo "<time to wait until switching routing control> <region to use for ARC> \\"
    echo "<endpoint to use for ARC> <first routing control ARN> <second routing control ARN"
    exit 1
fi
if [ "$INTERVAL" == "" ]
then
    echo "Usage: $0 <test stack name> <first region> <second region> <api url> <number of orders> \\"
    echo "<time to wait until switching routing control> <region to use for ARC> \\"
    echo "<endpoint to use for ARC> <first routing control ARN> <second routing control ARN"
    exit 1
fi
if [ "$ARCREGION" == "" ]
then
    echo "Usage: $0 <test stack name> <first region> <second region> <api url> <number of orders> \\"
    echo "<time to wait until switching routing control> <region to use for ARC> \\"
    echo "<endpoint to use for ARC> <first routing control ARN> <second routing control ARN"
    exit 1
fi
if [ "$ARCURL" == "" ]
then
    echo "Usage: $0 <test stack name> <first region> <second region> <api url> <number of orders> \\"
    echo "<time to wait until switching routing control> <region to use for ARC> \\"
    echo "<endpoint to use for ARC> <first routing control ARN> <second routing control ARN"
    exit 1
fi
if [ "$ARCCTRLA" == "" ]
then
    echo "Usage: $0 <test stack name> <first region> <second region> <api url> <number of orders> \\"
    echo "<time to wait until switching routing control> <region to use for ARC> \\"
    echo "<endpoint to use for ARC> <first routing control ARN> <second routing control ARN"
    exit 1
fi
if [ "$ARCCTRLB" == "" ]
then
    echo "Usage: $0 <test stack name> <first region> <second region> <api url> <number of orders> \\"
    echo "<time to wait until switching routing control> <region to use for ARC> \\"
    echo "<endpoint to use for ARC> <first routing control ARN> <second routing control ARN"
    exit 1
fi

ARNA=`aws cloudformation describe-stacks --stack-name $STACK --region $REGION | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="WorkflowArn").OutputValue'`
ARNB=`aws cloudformation describe-stacks --stack-name $STACK --region $OTHERREGION | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="WorkflowArn").OutputValue'`

aws stepfunctions start-execution \
  --region $REGION \
  --state-machine-arn $ARNA \
  --input "{\"num_items\": $ITEMS, \"url\": \"$APIURL\"}"
aws stepfunctions start-execution \
  --region $OTHERREGION \
  --state-machine-arn $ARNB \
  --input "{\"num_items\": $ITEMS, \"url\": \"$APIURL\"}"

STARTDT=`date`

echo "Test started at $STARTDT"

echo "Sleeping for $INTERVAL seconds..."

sleep $INTERVAL

echo "Switching routing control state..."

SWITCHDT=`date`
aws route53-recovery-cluster update-routing-control-states \
				--update-routing-control-state-entries '[{"RoutingControlArn": "'$ARCCTRLA'", "RoutingControlState": "Off"}, {"RoutingControlArn": "'$ARCCTRLB'", "RoutingControlState": "On"}]' \
				--region $ARCREGION \
				--endpoint-url $ARCURL
echo "Routing controls switched at $SWITCHDT"
