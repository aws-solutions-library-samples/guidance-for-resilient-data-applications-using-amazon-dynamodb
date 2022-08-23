# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

import json
import http.client
import urllib.parse
import os
from aws_synthetics.selenium import synthetics_webdriver as syn_webdriver
from aws_synthetics.common import synthetics_logger as logger
from aws_requests_auth.aws_auth import AWSRequestsAuth
from aws_requests_auth.boto_utils import BotoAWSRequestsAuth
import requests


def verify_request(apihandler, order, product, region, apistage):
    api_url = f"{apihandler}.execute-api.{region}.amazonaws.com"
    auth = BotoAWSRequestsAuth(aws_host=api_url,
        aws_region=region,
        aws_service='execute-api')

    user_agent = str(syn_webdriver.get_canary_user_agent_string())
    headers = {}
    if "User-Agent" in headers:
        headers["User-Agent"] = " ".join([user_agent, headers["User-Agent"]])
    else:
        headers["User-Agent"] = "{}".format(user_agent)

    logger.info("Making request with Method: 'GET' URL: %s" % ( api_url))
    response = requests.get(f"https://{api_url}/{apistage}/orders", params={"orderId": order, "productId": product}, auth=auth)
    logger.info("Status Code: %s " % response.status_code)

    if not response.status_code or response.status_code < 200 or response.status_code > 299:
        try:
            r = response.json()
            logger.error("Response: %s" % json.dumps(r))
        finally:
            raise Exception("Failed with status code: %s" % response.status_code)

    r = response.json()
    logger.info("Response: %s" % json.dumps(r))
    logger.info("HTTP request successfully executed")


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
