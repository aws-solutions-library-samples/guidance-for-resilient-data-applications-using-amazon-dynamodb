#!/usr/bin/env bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

templateprefix=cfn
templatebucket=$1
secondbucket=$2
thirdbucket=$3
stackname=resilientdynamo-canaries
firstregion=$4
secondregion=$5
obsregion=$6
apiname1=$7
apiname2=$8
apistagename=${9}
product=${10}
order=${11}
domainname=${12}
SCRIPTDIR=`dirname $0`
if [ "$templatebucket" == "" ]
then
    echo "First bucket name is required"
    echo "Usage: $0 <template bucket> <bucket in second region>\\"
    echo "<bucket in observer region> <stack name> <first region> <second region>\\"
    echo "<observer region> <api name in first region> <api name in second region>\\"
    echo "<api stage name> <sample product ID> <sample order ID> <domain name> <--update>"
    exit 1
fi
if [ "$secondbucket" == "" ]
then
    echo "Second bucket name is required"
    echo "Usage: $0 <template bucket> <bucket in second region>\\"
    echo "<bucket in observer region> <stack name> <first region> <second region>\\"
    echo "<observer region> <api name in first region> <api name in second region>\\"
    echo "<api stage name> <sample product ID> <sample order ID> <domain name> <--update>"
    exit 1
fi
if [ "$thirdbucket" == "" ]
then
    echo "Third bucket name is required"
    echo "Usage: $0 <template bucket> <bucket in second region>\\"
    echo "<bucket in observer region> <stack name> <first region> <second region>\\"
    echo "<observer region> <api name in first region> <api name in second region>\\"
    echo "<api stage name> <sample product ID> <sample order ID> <domain name> <--update>"
    exit 1
fi
if [ "$stackname" == "" ]
then
    echo "Stack name is required"
    echo "Usage: $0 <template bucket> <bucket in second region>\\"
    echo "<bucket in observer region> <stack name> <first region> <second region>\\"
    echo "<observer region> <api name in first region> <api name in second region>\\"
    echo "<api stage name> <sample product ID> <sample order ID> <domain name> <--update>"
    exit 1
fi
if [ "$firstregion" == "" ]
then
    echo "First region name is required"
    echo "Usage: $0 <template bucket> <bucket in second region>\\"
    echo "<bucket in observer region> <stack name> <first region> <second region>\\"
    echo "<observer region> <api name in first region> <api name in second region>\\"
    echo "<api stage name> <sample product ID> <sample order ID> <domain name> <--update>"
    exit 1
fi
if [ "$secondregion" == "" ]
then
    echo "Second region name is required"
    echo "Usage: $0 <template bucket> <bucket in second region>\\"
    echo "<bucket in observer region> <stack name> <first region> <second region>\\"
    echo "<observer region> <api name in first region> <api name in second region>\\"
    echo "<api stage name> <sample product ID> <sample order ID> <domain name> <--update>"
    exit 1
fi
if [ "$obsregion" == "" ]
then
    echo "Observer region name is required"
    echo "Usage: $0 <template bucket> <bucket in second region>\\"
    echo "<bucket in observer region> <stack name> <first region> <second region>\\"
    echo "<observer region> <api name in first region> <api name in second region>\\"
    echo "<api stage name> <sample product ID> <sample order ID> <domain name> <--update>"
    exit 1
fi
if [ "$apiname1" == "" ]
then
    echo "First API ID is required"
    echo "Usage: $0 <template bucket> <bucket in second region>\\"
    echo "<bucket in observer region> <stack name> <first region> <second region>\\"
    echo "<observer region> <api name in first region> <api name in second region>\\"
    echo "<api stage name> <sample product ID> <sample order ID> <domain name> <--update>"
    exit 1
fi
if [ "$apiname2" == "" ]
then
    echo "Second API ID is required"
    echo "Usage: $0 <template bucket> <bucket in second region>\\"
    echo "<bucket in observer region> <stack name> <first region> <second region>\\"
    echo "<observer region> <api name in first region> <api name in second region>\\"
    echo "<api stage name> <sample product ID> <sample order ID> <domain name> <--update>"
    exit 1
fi
if [ "$apistagename" == "" ]
then
    echo "API stage name is required"
    echo "Usage: $0 <template bucket> <bucket in second region>\\"
    echo "<bucket in observer region> <stack name> <first region> <second region>\\"
    echo "<observer region> <api name in first region> <api name in second region>\\"
    echo "<api stage name> <sample product ID> <sample order ID> <domain name> <--update>"
    exit 1
fi
if [ "$product" == "" ]
then
    echo "Sample product is required"
    echo "Usage: $0 <template bucket> <bucket in second region>\\"
    echo "<bucket in observer region> <stack name> <first region> <second region>\\"
    echo "<observer region> <api name in first region> <api name in second region>\\"
    echo "<api stage name> <sample product ID> <sample order ID> <domain name> <--update>"
    exit 1
fi
if [ "$order" == "" ]
then
    echo "Sample order is required"
    echo "Usage: $0 <template bucket> <bucket in second region>\\"
    echo "<bucket in observer region> <stack name> <first region> <second region>\\"
    echo "<observer region> <api name in first region> <api name in second region>\\"
    echo "<api stage name> <sample product ID> <sample order ID> <domain name> <--update>"
    exit 1
fi
if [ "$domainname" == "" ]
then
    echo "Domain name is required"
    echo "Usage: $0 <template bucket> <bucket in second region>\\"
    echo "<bucket in observer region> <stack name> <first region> <second region>\\"
    echo "<observer region> <api name in first region> <api name in second region>\\"
    echo "<api stage name> <sample product ID> <sample order ID> <domain name> <--update>"
    exit 1
fi
UPDATE=${14:-""}    
CFN_CMD="create-stack"
if [ "$UPDATE" == "--update" ]
then
    CFN_CMD="update-stack"
    echo "Updating stack"
fi

# Check if we need to append region to S3 URL
TEMPLATE_URL=https://s3.amazonaws.com/$templatebucket/$templateprefix/canary.yaml
TEMPLATE_URL_OBS=https://s3.amazonaws.com/$templatebucket/$templateprefix/canary-observer.yaml
if [ "$firstregion" != "us-east-1" ]
then
    TEMPLATE_URL=https://s3-$firstregion.amazonaws.com/$templatebucket/$templateprefix/canary.yaml
    TEMPLATE_URL_OBS=https://s3-$firstregion.amazonaws.com/$templatebucket/$templateprefix/canary-observer.yaml
fi

echo "Uploading CFN scripts"
aws s3 sync $SCRIPTDIR/../cfn s3://$templatebucket/$templateprefix

aws cloudformation $CFN_CMD --stack-name $stackname \
    --template-url $TEMPLATE_URL \
    --tags Key=Project,Value=resilientdynamo \
    --disable-rollback \
    --parameters \
    ParameterKey=Bucket,ParameterValue=$templatebucket \
    ParameterKey=ApiName,ParameterValue=$apiname1 \
    ParameterKey=ApiStageName,ParameterValue=$apistagename \
    ParameterKey=SampleProduct,ParameterValue=$product \
    ParameterKey=SampleOrder,ParameterValue=$order \
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
    --region $firstregion

aws cloudformation $CFN_CMD --stack-name $stackname \
    --template-url $TEMPLATE_URL \
    --tags Key=Project,Value=resilientdynamo \
    --disable-rollback \
    --parameters \
    ParameterKey=Bucket,ParameterValue=$secondbucket \
    ParameterKey=ApiName,ParameterValue=$apiname2 \
    ParameterKey=ApiStageName,ParameterValue=$apistagename \
    ParameterKey=SampleProduct,ParameterValue=$product \
    ParameterKey=SampleOrder,ParameterValue=$order \
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
    --region $secondregion

aws cloudformation $CFN_CMD --stack-name $stackname \
    --template-url $TEMPLATE_URL_OBS \
    --tags Key=Project,Value=resilientdynamo \
    --disable-rollback \
    --parameters \
    ParameterKey=Bucket,ParameterValue=$thirdbucket \
    ParameterKey=ApiName1,ParameterValue=$apiname1 \
    ParameterKey=ApiName2,ParameterValue=$apiname2 \
    ParameterKey=FirstRegion,ParameterValue=$firstregion \
    ParameterKey=SecondRegion,ParameterValue=$secondregion \
    ParameterKey=ObsRegion,ParameterValue=$obsregion \
    ParameterKey=ApiStageName,ParameterValue=$apistagename \
    ParameterKey=SampleProduct,ParameterValue=$product \
    ParameterKey=SampleOrder,ParameterValue=$order \
    ParameterKey=DomainName,ParameterValue=$domainname \
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
    --region $obsregion
