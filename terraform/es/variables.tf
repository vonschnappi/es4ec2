variable "es_instance_type" {
  type    = string
  default = "t3.small.elasticsearch"
}

variable "es_domain_name" {
  type    = string
  default = "es4ec2"
}

variable "es_subnet" {
  type = list(string)
}

variable "es_security_group" {
  type = list(string)
}

