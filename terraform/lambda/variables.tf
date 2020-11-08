variable lambda_name {
  type = string
}

variable "es_endpoint" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
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

