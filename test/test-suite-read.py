import json
import requests
import uuid
import boto3
from botocore import crt, awsrequest

def get_headers_sigv4a(service, region, method, url):
    sigV4A = crt.auth.CrtS3SigV4AsymAuth(boto3.Session().get_credentials(), service, region)
    request = awsrequest.AWSRequest(method=method, url=url)
    sigV4A.add_auth(request)
    prepped = request.prepare()

    return prepped.headers

# URL looks like: https://<url>/v1/orders?customerId=foo&productId=bar&orderId=baz
def lambda_handler(event, context):
    print(json.dumps(event))
    api_url = event['url']
    cust = event['order']['customer']
    prod = event['order']['product']
    order = str(uuid.uuid4())
    print(f"Generating order for customer {cust} and product {prod}, using ID {order}")

    service = 'execute-api'
    region = '*'
    method = 'POST'
    url = f"https://{api_url}/v1/orders?customerId={cust}&orderId={order}&productId={prod}"

    headers = get_headers_sigv4a(service, region, method, url)
    r = requests.post(url, headers=headers)

    print(f"Response from post: {r.status_code}")
    if r.status_code > 299:
        raise Exception(f"Got invalid return code from request: {r.status_code}")

    url = f"https://{api_url}/v1/orders?orderId={order}&productId={prod}"
    method = 'GET'
    headers = get_headers_sigv4a(service, region, method, url)
    r = requests.get(url, headers=headers)
    print(f"Response from get: {r.status_code}")
    if r.status_code > 299:
        raise Exception(f"Got invalid return code from request: {r.status_code}")

    return {'status': 200}