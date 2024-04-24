import json
import boto3
import requests
import os
from botocore import crt, awsrequest

max_batch = int(os.environ['MAX_BATCH_SIZE'])

def get_headers_sigv4a(service, region, method, url):
    sigV4A = crt.auth.CrtS3SigV4AsymAuth(boto3.Session().get_credentials(), service, region)
    request = awsrequest.AWSRequest(method=method, url=url)
    sigV4A.add_auth(request)
    prepped = request.prepare()

    return prepped.headers

# URL looks like: https://<url>/v1/fill?cust=20&order=0&product=20
def lambda_handler(event, context):
    print(json.dumps(event))
    num_items = int(event['num_items'])
    api_url = event['url']
    print(f"Generating {num_items} items by calling {api_url}")
    responses = []

    service = 'execute-api'
    region = '*'
    method = 'POST'

    processed = 0

    while processed < num_items:
        next_batch = max_batch
        remaining = num_items - processed
        if remaining < max_batch:
            next_batch = remaining
        print(f"Generating {next_batch} items, {processed} already done, {remaining} left")

        url = f"https://{api_url}/v1/fill?cust={next_batch}&order=0&product={next_batch}"
        headers = get_headers_sigv4a(service, region, method, url)
        response = requests.post(url, headers=headers)

        print(response)
        r = response.json()
        print(r)
        p = r['products']
        c = r['customers']
        for prod,cust in zip(p,c):
            responses.append({'customer': cust, 'product': prod})
        processed = processed + next_batch

    return {'items': responses}