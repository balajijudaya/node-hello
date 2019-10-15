# node-hello
A simple hello world node js application


# Running the app
>npm start

# Assumptions

1. A jenkins server hosted on-prem / on aws exists with the necessary plugins installed (aws credentials plugin, docker plugin etc).
2. AWS credentials set up in jenkins server (separate user in case of on-prem server, role in case of aws hosted).
3. A jenkins job created with git source https://github.com/balajijudaya/node-hello.git which looks for Jenkinsfile at the root for pipeline script.
4. Github webhook set up to trigger jenkins job on code checkins.

# Things Covered As Part Of Assesment

## Automated Infra Provisioning in AWS and Deployment using Terraform

1. Terraform will provision the infrastructue in aws including VPC, subnets, internet gateway, NAT gateway, route tables, security groups, etc.
2. Terraform will provision a ECS(Fargate) cluster to run the node service based on the task definition template.
3. ECS service is configures to autoscale based on CPU usage (with cloudwatch monitoring).
4. Application Load Balancer will act as a Front for user requests which will route requests to the ECS service.
5. Terraform will pick up latest docker image from ECR and deploy to stage and prod ECS clusters.
6. Terraform infrastructure state is managed using s3 buckets and dynamo db tables for stage and prod environments so that terraform always knows the current state of the infrastructure.
7. Manual deployment using terraform

#### Bootstrap state components
```
cd bootstrap
terraform init
terraform plan
terraform apply
```

#### For stage environment
```
terraform init -backend-config=stage-backend.tfvars
```
```
terraform plan -var-file=stage.tfvars
```
```
terraform apply -var-file=stage.tfvars
```

#### For prod environment
```
terraform init -backend-config=prod-backend.tfvars
```
```
terraform plan -var-file=prod.tfvars
```
```
terraform apply -var-file=prod.tfvars
```

## CI CD Pipeline

When jenkins job is triggerred by github webhook / manual trigger, pipeline will be executed.
1. npm dependencies will be installed.
2. npm unit test will be run.
3. New docker image based on the Dockerfill will be built and tagged as latest.
4. Docker image built will be pushed to aws ECR.
5. Terraform script is triggerred to deploy the latest docker images to stage environment ECS cluster.
6. A cucumber selenium functional test is run against the stage environment(latest deployment).
7. Once regression suite succeeds, jenkins will prompt the user for approval to promote the deployment to prod.
8. On approval terraform script will be triggerred to deploy to production. On 'cancel' jenkins job will be aborted.
9. During any failure in any of the above steps will cause the jenkins build to fail and abort and send out an failure email.

# TODOs

1. ALB url will be the url used by the users to access the node app. Route 53 DNS is not implemented.
2. No alerting implemented in case of service unavailability. But email will be sent in case of build / test / deployment failures.
