
# Node.js AWS CI/CD Strategy

This is a CI/CD strategy for a simple Node/Express application integrating CodeBuild, CodeDeploy, and CodePipeline. It is advisable to understand the purpose and functionality of these individual AWS services and how they fit together to create a CI/CD pipeline.

## File Structure

### Root Folder
The root folder contains buildspec.yml and appspec.yml files for CodeBuild and CodeDeploy respectively. Note that .eslintrc.json is included for linting during the build/test process in the cloud. It should not be included in the .gitignore file for this reason (unless linting is done via an additional npm package and script). The root folder also includes standard Node/Git project files: package.json and .gitignore.

### /cloudformation-templates
The cloudformation-templates folder contains the necessary CloudFormation templates for CodeBuild, CodeDeploy, and CodePipeline as well as parameters.json (which is .gitignored since it contains a GitHub token).

### /scripts
The scripts folder contains script files related to the project.

### /test
The test folder contains spec files for unit testing. In this boilerplate, Mocha/SuperTest are used as a testing suite.

### /src
All code related to the Node App should be located in the /src folder.

## Getting Started
```
npm install
```
### Lint/Test
Make sure your project successfully lints and tests with no errors. Mocha must be installed globally.
```
npm run lint
npm test
```

### Commit to GitHub
Commit this repo to GitHub and note the repo name and branch you'd like to track for deployment.

### Add parameters.json
Retrieve a GitHub token that allows AWS to source and watch your repo. You must also retrieve an existing key name for your EC2 instances (or create a new key in the EC2 console). Create a file named parameters.json in the cloudformation-templates folder that follows the given pattern:
```
[
  {
    "ParameterKey": "GitHubToken",
    "ParameterValue": <Your GitHub Token>
  },
  {
    "ParameterKey": "GitHubRepoOwner",
    "ParameterValue": <Your GitHub Name>
  },
  {
    "ParameterKey": "GitHubRepoName",
    "ParameterValue": <Name of the GitHub Repo>
  },
  {
    "ParameterKey": "GitHubBranch",
    "ParameterValue": <Name of the Branch>
  },
  {
    "ParameterKey": "S3ArtifactStore",
    "ParameterValue": "codepipeline-us-east-1-<Provide a unique identifier here>"
  },
  {
    "ParameterKey": "EC2KeyName",
    "ParameterValue": <Name of existing Key for EC2 ssh capability>
  }
]
```

### Run CloudFormation Script
This script will create the necessary resources for your CodeBuild projects (test & deployment), CodeDeploy application/group, and CodePipeline. It is highly likely you will need to edit these resources for your particular app's needs. You can deploy all the resources with the following command:
```
npm run cloudformation
```
You can also deploy individual parts of the CloudFormation stack with the following commands:
```
npm run cloudformation-build
npm run cloudformation-deploy
npm run cloudformation-pipeline
```

## CloudFormation Stacks

### CodeBuild
The code-build.yml CloudFormation template creates the following resources:
* IAM Role for the CodeBuild project with attached policy
* CodeBuild project for testing with configurable lifecycle commands. You'll likely want to edit the commands (see CodeBuild Notes) and environment (Node version, Linux Container).
* CodeBuild project for deployment


### CodeDeploy
The code-deploy.yml CloudFormation template creates the following resources:
* Instance Security Group with ports 22 and 8080 availaible to all IPs (You'll likely want to change these security protocols.)
* IAM Role for EC2 instance with IAM Policy allowing Get and List access to S3
* EC2 Instance Profile with aforementioned IAM Role attached
* EC2 LaunchConfiguration with UserData script that installs Ruby, AWS-CLI, CodeDeploy software, and NodeJS (You'll likely want to edit the InstanceType and configure additional parameters for your specific project.)
* AutoScalingGroup with tags necessary for CodeDeploy (You'll likely want to edit MinSize, MaxSize, Availability Zones, and configure additional parameters for your specific project)
* IAM Role and Policy for CodeDeploy
* CodeDeploy Application with EC2 TagFilters referencing the tags attached to the AutoScaling Group

### CodePipeline
The code-pipeline.yml CloudFormation template creates the following resources:
* S3 Bucket to hold source code and build artifacts
* IAM Role for CodePipeline with attached IAM Policy
* CodePipeline with following stages
  * Source (connects to GitHub Repo and Branch)
  * Test (CodeBuild project named RepoName-BranchName-Test) which can be configured in the code-build.yml Cloudformation template under the resource property: TestCodeBuildProject
  * Build (CodeBuild project named RepoName-BranchName) which is configured by the buildspec.yml in the root folder and the code-build.yml Cloudformation template under the resource property: CodeBuildProject
  * Deploy (CodeDeploy application named RepoName-BranchName) which is configured by appspec.yml and the code-deploy.yml Cloudformation template resource properties: DeployApplication and DeploymentGroup

## CodeBuild Notes
There two CodeBuild projects in the CodePipeline created by the Cloudformation templates: a test build and a build for deployment.

### Test Build
In order to configure the test build, most of the options are located in the code-build.yml template under the resource name: TestCodeBuildProject. In the Source.BuildSpec.phases properties, you are able to perform multiple commands in different parts of the build's lifecycle. This boilerplate includes:
* Install phase:
    * npm install
    * npm install -g mocha
* Pre_build phase:
    * npm run lint
* Build phase
    * npm test

Worth noting: if any of these lifecycle commands produces an error, the build will fail and the pipeline will stop.

### Build for Deployment
If the test build passes, the pipeline continues with the deployment build. The CodeBuild project looks at the buildspec.yml located in the root folder for lifecycle commands. The build exports the necessary artifacts to the S3 bucket created in the codepipeline.yml template. In this boilerplate, all the folders/files are included recusively ```'**/*'``` as artifacts of the build. If you only want to export specific files or folders from the build phase for the deployment phase, they can be declared in the artifacts property of the buildspec.yml.

## CodeDeploy Notes
Deployment will largely depend on the needs of your specific app. In this boilerplate, an autoscaling group of EC2 instances is deployed. The configuration of your deployment is largely defined in the code-deploy.yml template. It's important to note that if you change the name of your deployment application or deployment group, that change will need to be reflected in the 'Deploy' phase of your CodePipeline, located in codepipeline.yml.

## Helpful Resources

#### CodeBuild
[CodeBuild Docs](https://docs.aws.amazon.com/codebuild/latest/userguide/welcome.html)

[CodeBuild Cloudformation Docs](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-codebuild-project.html)

#### CodeDeploy
[CodeDeploy Docs](https://docs.aws.amazon.com/codedeploy/latest/userguide/welcome.html)

[CodeDeploy Cloudformation Docs](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-codedeploy-application.html)

#### CodePipeline
[CodePipeline Docs](https://docs.aws.amazon.com/codepipeline/latest/userguide/welcome.html)

[CodePipeline Cloudformation Docs](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-codepipeline-pipeline.html)
