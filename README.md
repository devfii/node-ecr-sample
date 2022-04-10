# Using ECR to host Docker images
This project contains a sample NodeJS app and supporting code to build a container image from it and push to an ECR repository.
It includes the following files and folders:
* cloudformation
* iam
* terraform
* package.json
* package-lock.json
* Dockerfile
* server.js
The project requires an ECR repository, an ECR repository policy and an IAM policy to be attached to an existing IAM user.
The user may decide to either use the AWS CLI to create these resources or CloudFormation or Terraform.

The cloudformation folder contains a template file to create the resources above. 
The IAM folder contains resource-based policy to be applied to the repository and an identity-based policy to be attached to an IAM user.
The terraform folder contains files to create the aforementioned resources using Terraform CLI.
The server.js file contains Node JS code to be containerized. The Dockerfile contains the commands to containerize the Node JS code.

## Prerequites
* Docker CLI
* AWS Account
* IAM User
* AWS CLI 
* Terraform (Optional)
  
## Create the AWS resources

### Using AWS CLI
To use the the AWS CLI, you should have the AWS CLI on your client configured with access keys with permissions to create an ECR repository, ECR repository policy and an IAM policy.

To create a repository, use:

```
aws ecr create-repository --repository-name node-ecr-sample
```
We can now add our repository policy which grants permissions to specified IAM user(s) on the repository.
Don't forget to replace the <ACCOUNT-ID> and <IAM-USER> placeholders which your account id and IAM user respectively.
 ```
  aws ecr set-repository-policy --repository-name node-ecr-sample \
  --policy-text file://iam/repo-policy.json
 ```
  
We can now create an identity-based policy for our IAM user. We name the policy IAMECRPolicy .
  ```
  aws iam create-policy --policy-name IAMECRPolicy --policy-document file://iam/user-iam-ecr-policy.json
  ```
  
To grant an IAM user permissions to the ECR registry. Use the below commands. Replace the placeholders with your values.
  ```
  aws iam attach-user-policy --policy-arn arn:aws:iam:<ACCOUNT-ID>:aws:policy/IAMECRPolicy --user-name <IAM-USER>
  ```
To clen up when done, we use the below commands. We use the force flag when the repository has images to delete the images and then the repository.
  ```aws ecr delete-repository --repository-name node-ecr-sample --force ```
  
## Using Terraform
Terraform is another alternative we can use to create our AWS resources.
If don't have Terraform installed, you can refer to this [repository](https://github.com/devfii/intro-tf/blob/main/README.md#installing-terraform) to have it installed.

To use Terraform to create your resources, switch to the terraform directory.

```cd terraform```

Create a terraform.tfvars file to define the variables used. Please provide your own values.

```
cat > terraform.tfvars
iam_user = ""
account_id = ""
region = ""
repository_name = ""
iam_policy_name = ""
```

Use the below set of commands to create your resources
```
terraform init
terraform validate
terraform plan
terraform apply
```

To clean up, run ```terraform destroy```

## Using Coudformation
We can also use a CloudFormation template to create a stack for this project. The template creates the ECR repository, attaches a repository policy to it and creates an IAM policy which has permissions to authenticate with the ECR registry, list repositories and create repositories. The IAM policy is attached to an IAM User you provide as a parameter.

Before, we create the stack, we can validate our template using the below commands

```aws cloudformation validate-template --template-body file://cloudformation/ecr-template.yaml```

Now, we create the stack using the below commands

```
aws cloudformation create-stack --stack-name node-ecr-sample-repo --template-body file://cloudformation/ecr-template.yaml  \
--parameters ParameterKey=IAMUser,ParameterValue=<IAM-USER> ParameterKey=RespositoryName,ParameterValue=<REPOSITORY-NAME>
``` 

To clean up, run the following command

```aws cloudformation delete-stack --stack-name node-ecr-sample-repo```


## Authenticating with ECR registry
There are two options to authenticate your Docker clientwith your ECR repository. These are:
  1. [ECR credential helper](https://github.com/awslabs/amazon-ecr-credential-helper)
  2. AWS CLI
  
     Run the below command
     ```
     aws ecr get-login-password --region region | docker login --username AWS \
     --password-stdin aws_account_id.dkr.ecr.region.amazonaws.com
     ```

## Build, Tag and Push Image to ECR 
From the root directory of this repo, we can build our container image by running below commands

  ```
docker build -t node-ecr-sample:v1 .
  ```
  
We can now tag the container image with our ECR repository url
```
  docker tag node-sample:v1 <aws_account_id>.dkr.ecr.<region>.amazonaws.com/node-ecr-sample:v1
```
Then we push the container image to the ECR repository
  ```
  docker push <aws_account_id>.dkr.ecr.<region>.amazonaws.com/node-ecr-sample:v1
  ```
Locally, we can view the container images by using below
```
docker images
```
To view the container image in the ECR repository, use below
```
aws ecr describe-images --repository-name node-ecr-sample
```

To pull our image from the ECR registry, we use below
```
docker pull <account-id>.dkr.ecr.<your-region>.amazonaws.com/node-ecr-sample:v1
```

To delete the image from the ECR registry, we use below
  
```
aws ecr batch-delete-image --repository-name node-ecr-sample --image-ids imageTag=v1 
```
