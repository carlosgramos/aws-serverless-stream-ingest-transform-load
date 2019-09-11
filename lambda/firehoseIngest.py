import json
import urllib.parse
import os
import boto3
from aws_xray_sdk.core import xray_recorder
from aws_xray_sdk.core import patch_all
patch_all()

print('Loading function')

s3 = boto3.client('s3')
kinesis = boto3.client('firehose')
delivery_stream = os.environ['INGEST_STREAM']

def lambda_handler(event, context):
    #print("Received event: " + json.dumps(event, indent=2))
    
    # Get the object from the event and show its content type
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    
    try:
        s3_response = s3.get_object(Bucket=bucket, Key=key)
        
        #Build logic to send txt file with station ID/names to glue for processing
        #If S3 object key contains .txt, then send to glue
        
        #Build logic to send weather data to kinesis firehose for possible ETL
        kinesis_response = kinesis.put_record(
            DeliveryStreamName=delivery_stream,
            Record={
                'Data': s3_response['Body'].read()
            }
        )
        
        print(kinesis_response)
        
        return 'Records ingested into Firehose.'
    except Exception as e:
        print(e)
        print('Error getting object {} from bucket {}. Make sure they exist and your bucket is in the same region as this function.'.format(key, bucket))
        raise e