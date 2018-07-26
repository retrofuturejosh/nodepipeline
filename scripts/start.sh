#!/bin/bash

#create resources
echo creating resources
aws cloudformation create-stack --stack-name node-app-stack --template-body file://resources.yml --capabilities CAPABILITY_IAM --parameters file://parameters.json

echo waiting for successful creation of stack
#wait for resources to be created
aws cloudformation wait stack-create-complete --stack-name node-app-stack

echo creating pipeline
#create pipeline
aws cloudformation create-stack --stack-name node-pipeline-stack --template-body file://codepipeline.yml --capabilities CAPABILITY_IAM --parameters file://parameters.json

echo waiting for successful creation of pipeline
#wait for pipeline to be created
aws cloudformation wait stack-create-complete --stack-name node-pipeline-stack

echo succesfully created resources and pipeline
exit
