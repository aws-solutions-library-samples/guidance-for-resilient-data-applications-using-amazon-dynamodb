# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

import sys
import boto3
from botocore import crt, awsrequest
from urllib.request import urlopen, Request
from urllib import parse

def get_headers_sigv4a(session, service, region, method, url):
    sigV4A = crt.auth.CrtS3SigV4AsymAuth(session.get_credentials(), service, region)
    request = awsrequest.AWSRequest(method=method, url=url)
    sigV4A.add_auth(request)
    prepped = request.prepare()

    return prepped.headers

def send_post_request(api_url):
    data = parse.urlencode({}).encode()
    headers = get_headers_sigv4a(boto3.Session(), "execute-api", '*', "POST", api_url)
    httprequest = Request(api_url, headers=headers, data=data)
    
    with urlopen(httprequest) as response:
        print(response.status)
        print(response.read().decode())
    
    if not response.status or response.status < 200 or response.status > 299:
        raise Exception("Failed with status code: %s" % response.status)   

base_url = sys.argv[1]
api_url = f"{base_url}/fill?cust=20&order=0&product=20"
send_post_request(api_url)


