# Elasticsearch for EC2 State

This project was created in order to solve two issues that I've repeatedly come across when working with EC2s.

* If the number of instances you are running reaches the thousands, it's really hard to load and search for instances in AWS UI. It's faster in the CLI but you have to use pagination.
* There's nothing out of the box for retaining history of terminated instances. It's possible to look for these in cloudwatch events or cloudtrail, but for a quick search that can plugged into API, elasticsearch is much better.

# The Stack
* Terraform
* Python3.8
* AWS Elasticsearch - in the future I hope to expand by adding a module for deploying a self-managed ES cluster
* Lambda function 

# End Result of Running this Project
If you run this project (details ahead) you will end up with an AWS Elasticsearch that contains two indices:
1. `instance-state` - for the state of the instance (pending, running, stopping, stopped, terminated)
2. `instance-detail` - for instance details - extremly useful for seeing the details of terminated instances.


# What's Created when Running this Project
This is list of what's created in AWS and why it's created.

## Networking
The project creates a dedicated VPC with the following components:
* **An internet gateway**.
* **A Nat Gateway** - the nat gateway is used in order to give the lambda access to the internet. A lambda deployed to a VPC loses internet access, and it needs it because it's making API requests to AWS using boto3. Read more about [giving lambda internent access](https://aws.amazon.com/premiumsupport/knowledge-center/internet-access-lambda-function/).
* **Two route tables** - One with an internet gateway attached to it. The AWS elasticsearch clustere AWS Elasticsearch domain. The domain is deployed in a VPC and is not publicly accesible so there has to be an instance that allows you to access the AWS Elasticsearch kibana.
  * **Two private ones** - where the AWS Elasticsearch domain and the lambda are deployed. The lambda is deployed in the private subnets because it must be deployed in the VPC or it won't be able to send index requests to the AWS Elasticsearch domain. Also, there are two private subnets because AWS recommends deploying lambda in two subnets for high-availability.
* **A small Amazon-linux-2 instance** -  deployed in the public subnet so that we can ssh into it and tunnel traffic to the AWS Elasticsearch domain, mainly for accessing kibana.
* **An elastic IP to attach to the nat gateway**
* **Two security groups**
  * One that allows you to ssh into at the instance that tunnels traffic to the AWS elasticsearch cluster (for accessing kibana).
  * Another for grantsw the first security group  access through known Elasticsearch ports (9200, 5601) as well as 443.

## Computing
The computing components are responsible for indexing and viewing EC2 state chagne and instance details.
### AWS Elasticsearch
I've chosen an AWS elasticsearch cluster because it's easier to setup and much easier to secure. It's a very small cluster that consists of one data node which is also the master node, and one kibana. To deploy a bigger cluster, or use bigger nodes, edit the `main.tf` file in the es module. See [Terraform AWS elasticsearch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticsearch_domain) for more information. 

This AWS elasticsearch cluster is deployed in the VPC that is created by this project. Therefore it's not publicly accessible excpet when creating an ssh tunnel using the small EC2 instance that is also deployed. In the process of creating the AWS elasticsearch cluster it gets a policy defined for it that allows public access. It's not really allowing public access, but just makes it discoverable for other resources in the VPC such as EC2 instances and lambdas.

### EC2 Instance
The EC2 instance doesn't really do anything, apart from allowing [SSH tunneling into the AWS Elasticsearch cluster to internact with Kibana](https://aws.amazon.com/premiumsupport/knowledge-center/internet-access-lambda-function/).

### Lambda
The lambda is triggered by a cloudwatch event rule that sends it events every time an EC2 instance is launched, stopped or terminated. The lambda indexes these events in the AWS Elasticsearch cluster. For example:
1. an instance is launched. 
2. Cloudwatch triggers the lambda with the details about the EC2 instance and its state.
3. Lambda either indexes the new instance or updates its state in the `instance-state` index.
4. The lambda also takes the instance ID and pulls out its details using boto3. It then indexes the details in the index `instance-detail`.

# Launching the Stack
In the root folder of this project, run `./deploy.sh`


# Things to Consider and Gotchas
* Launching an AWS Elasticsearch cluster takes somehting between 10-15 minutes. Take that into account when launching the stack.
* Every instance type and other parameters are basic and the smallest possible. You might want to up the instance type for the AWS Elasticsearch cluster and deploy it with a master node and two data nodes, depending on the expected load.
* The lambda is very simple and doesn't implement error handling or retries.



