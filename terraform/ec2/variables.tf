variable "kibana_access_security_group" {
  type = list(string)
}

variable "kibana_access_subnet" {
  type = list(string)
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