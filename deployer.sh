#!/usr/bin/env bash

echo 'Please enter the bucket cloudformation will use to upload artifacts: '
read S3Bucket 

echo 'Please enter the AWS region where you will depploy the stacks: '
read REGION

FILE="$(uuidgen).yaml"
PREFIX=serverless/firehose

cd lambda-layer
[[ -d python ]] || mkdir python
python3 -m pip install -r requirements.txt -t python --upgrade
cd ..

[[ -d packaged-templates ]] || mkdir packaged-templates

aws cloudformation package --region $REGION --template-file streaming_ingest_transform_load.yml --s3-bucket $S3Bucket --s3-prefix $PREFIX --output-template-file packaged-templates/"$FILE"
aws cloudformation deploy --region $REGION --template-file packaged-templates/"$FILE" --stack-name StreamingITL-"$(uuidgen)" --capabilities CAPABILITY_NAMED_IAM
