# Dcentralab Project
The following project shows the deployment of an AWS serverless application.
The architecture contains the following resources:
- 2 Api GateWays
- 2 Lambda function
- RDS Proxy
- RDS Instance
- RDS Instance Replica

## Terraform Files
The serverless architecture was created using terraform without the use of modules.
The terraform deploys:
1. VPC - used to host the infrastructure networking environment.
2. Subnets - 2 subnets are used for DR.
3. Internet Gateway - for the subnets to be public subnets.
4. Routes - a routing table for public access.
6. RDS instance - the rds hosts the database "rdslambda" containing the hw table.
7. RDS Proxy - used for authenticating to the RDS instance, the RDS Proxy allows for IAM authentication, and scalable serverless applicaion.
8. Lambda - 2 lambda function, Store-Values and Get-Values, the first is used to create the "hw" table and for inserting values to the table and the second gets all the values and returns them to the api gateway.
9. Api GateWay - 2 GET rest api gateways, one for each lambda fucntion accessible from the browser.

## GitHub Action
GitHub action is used to deploy the application and is divided into 2:
- PR opened: when the PR first open the workflow is triggered to run terraform fmt,validate,plan. Afterwards the terraform plan is saved as an artifact for the terraform apply command and commented on the PR.
- PR closes: When the PR is approved the workflow triggeres again, this time it retrives the artifact from previous workflow and uses it to run terraform apply.