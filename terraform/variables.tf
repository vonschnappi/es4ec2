variable "cloud_watch_rule_name" {
  type = string
}
variable "cloud_watch_rule_description" {
  type = string
}

variable "ec2_instance_policy_name" {
  type = string
}

variable "ec2_instance_policy_description" {
  type = string
}

variable "ec2_instance_role_name" {
  type = string
}

variable "es_domain_name" {
  type = string
}
variable "es_instance_type" {
  type = string
}

variable "lambda_name" {
  type = string
}
variable "lambda_iam_role_name" {
  type = string
}

variable "lambda_execution_role_name" {
  type = string
}

variable "lambda_execution_role_description" {
  type = string
}
