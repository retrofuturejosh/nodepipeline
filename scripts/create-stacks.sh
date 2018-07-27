#!/bin/bash

#create code-build resource
echo creating codebuild resources
aws cloudformation create-stack --stack-name node-app-codebuild-resources --template-body file://cloudformation-templates/code-build.yml --capabilities CAPABILITY_IAM --parameters file://cloudformation-templates/parameters.json

#wait for resources to be created
echo waiting for successful creation of stack
aws cloudformation wait stack-create-complete --stack-name node-app-codebuild-resources

#create code-deploy resources
echo creating codedeploy resources
aws cloudformation create-stack --stack-name node-app-codedeploy-resources --template-body file://cloudformation-templates/code-deploy.yml --capabilities CAPABILITY_IAM --parameters file://cloudformation-templates/parameters.json

#wait for resources to be created
echo waiting for successful creation of stack
aws cloudformation wait stack-create-complete --stack-name node-app-codedeploy-resources

echo creating pipeline
#create pipeline
aws cloudformation create-stack --stack-name node-pipeline-stack --template-body file://cloudformation-templates/codepipeline.yml --capabilities CAPABILITY_IAM --parameters file://cloudformation-templates/parameters.json

#wait for resources to be created
echo waiting for successful creation of stack
aws cloudformation wait stack-create-complete --stack-name node-pipeline-stack

echo succesfully created resources and pipeline
exit
