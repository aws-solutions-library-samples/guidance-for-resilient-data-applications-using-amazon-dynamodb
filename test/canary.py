# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

import os
import logging
import boto3
from botocore.auth import SigV4Auth
from botocore.awsrequest import AWSRequest
from urllib.request import urlopen, Request

logger = logging.getLogger('logger')

def verify_request(apihandler, order, product, region, apistage):
    method = "GET"
    service = "execute-api"
    host = f"{apihandler}.execute-api.{region}.amazonaws.com"
    api_url = f"https://{host}/{apistage}/orders?orderId={order}&productId={product}"

    session = boto3.Session(region_name=region)
    request = AWSRequest(method, api_url, headers={'Host': host})
    SigV4Auth(session.get_credentials(), service, region).add_auth(request)

    httprequest = Request(api_url, headers=dict(request.headers))

    with urlopen(httprequest) as response:
        print(response.status)

    if not response.status or response.status < 200 or response.status > 299:
        raise Exception("Failed with status code: %s" % response.status)

def main():

    product = os.environ['ProductId']
    order = os.environ['OrderId']
    apihandler = os.environ['ApiName']
    apiregion = os.environ['ApiRegion']
    apistage = os.environ['ApiStage']

    verify_request(apihandler, order, product, apiregion, apistage)

    logger.info("Canary successfully executed")


def handler(event, context):
    logger.info("Selenium Python API canary")
    main()