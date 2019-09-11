#!/usr/bin/env bash

# echo 'Please enter the bucket cloudformation will use to upload artifacts: '
# read S3Bucket 

# echo 'Please enter the AWS region where you will depploy the stacks: '
# read REGION

S3Bucket='firehose-micro-arch-artifacts-82019'
REGION='us-east-1'

FILE="$(uuidgen).yaml"
PREFIX=serverless/firehose

cd lambda/
pip3 install -r requirements.txt -t "$PWD" --upgrade
cd ..
aws cloudformation package --region $REGION --template-file streaming_ingest_transform_load.template --s3-bucket $S3Bucket --s3-prefix $PREFIX --output-template-file $FILE
aws cloudformation deploy --region $REGION --template-file $FILE --stack-name StreamingITL --capabilities CAPABILITY_NAMED_IAM
