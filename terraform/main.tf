provider "aws" {
  region = "us-east-1"
}

module "network" {
  source = "./network"
}

module "es" {
  source            = "./es"
  es_domain_name    = var.es_domain_name
  es_instance_type  = var.es_instance_type
  es_subnet         = [module.network.es_4_ec2_private_subnet_id1]
  es_security_group = [module.network.es_kibana_security_group_id]
}

module "lambda" {
  source                            = "./lambda"
  lambda_name                       = var.lambda_name
  subnet_ids                        = [module.network.es_4_ec2_private_subnet_id1, module.network.es_4_ec2_private_subnet_id2]
  security_group_ids                = [module.network.ssh_security_group_id]
  es_endpoint                       = module.es.es_endpoint
  lambda_iam_role_name              = var.lambda_iam_role_name
  lambda_execution_role_name        = var.lambda_execution_role_name
  lambda_execution_role_description = var.lambda_execution_role_description
}

module "cloudwatch" {
  source                       = "./cloudwatch"
  lambda_name                  = module.lambda.lambda_name
  lambda_arn                   = module.lambda.lambda_arn
  cloud_watch_rule_name        = var.cloud_watch_rule_name
  cloud_watch_rule_description = var.cloud_watch_rule_description
}

module "ec2" {
  source                          = "./ec2"
  kibana_access_security_group    = [module.network.ssh_security_group_id]
  kibana_access_subnet            = [module.network.es_4_ec2_public_subnet_id]
  ec2_instance_policy_name        = var.ec2_instance_policy_name
  ec2_instance_policy_description = var.ec2_instance_policy_description
  ec2_instance_role_name          = var.ec2_instance_role_name
}

