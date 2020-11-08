import csv
import json
from elasticsearch import Elasticsearch, RequestsHttpConnection
from requests_aws4auth import AWS4Auth
import boto3
import sys
import os

# Host for es endpoint comes from the outputs of the es module in terraform\
# and injected as an env var
host = os.environ['es_endpoint']
region = os.environ['AWS_REGION']
service = 'es'

# Lambda has an execution role that allows it to perform all action 
# against the aws elasticsearch domain. For that reason, we need to ask
# boto3 for the session credentials, these are dynamically created in every
# lambda execution
credentials = boto3.Session().get_credentials()
awsauth = AWS4Auth(credentials.access_key, credentials.secret_key, region, service, session_token=credentials.token)

# Standard aws elasticsearch config for elsaticsearch object
es = Elasticsearch(
    hosts = [{'host': host, 'port': 443}],
    http_auth = awsauth,
    use_ssl = True,
    verify_certs = True,
    connection_class = RequestsHttpConnection,
    timeout=30, 
    max_retries=1, 
    retry_on_timeout=True
)

# For getting the instance details to put in the instance-detail index 
def get_instance_details(instance_id):
    client = boto3.client(
        'ec2',
        aws_access_key_id=credentials.access_key,
        aws_secret_access_key=credentials.secret_key,
        aws_session_token=credentials.token
    )
    res = client.describe_instances(InstanceIds=[instance_id])
    return res['Reservations'][0]['Instances'][0]
    

# Two actions performed here:
# 1. Indexing the state of the instance
# 2. Indexing the details of the instance
# The second step is to preserve instance details of instances that have been terminated 
def lambda_handler(event, context):
    res = es.index(index="instance-state", id=event['detail']['instance-id'], body=event)
    instance_details = get_instance_details(event['detail']['instance-id'])
    res = es.index(index="instance-detail", id=event['detail']['instance-id'], body=instance_details)
    
