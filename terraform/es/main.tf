resource "aws_elasticsearch_domain" "ec2state" {
  domain_name           = var.es_domain_name
  elasticsearch_version = "7.8"

  cluster_config {
    instance_type = var.es_instance_type
  }

  vpc_options {
    subnet_ids         = var.es_subnet
    security_group_ids = var.es_security_group
  }

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  ebs_options {
    ebs_enabled = true
    volume_type = "gp2"
    volume_size = "80"
  }

  tags = {
    Domain = var.es_domain_name
  }
}

resource "aws_elasticsearch_domain_policy" "allow_open_acccess" {
  domain_name = aws_elasticsearch_domain.ec2state.domain_name

  access_policies = <<POLICIES
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "es:*",
      "Resource": "arn:aws:es:us-east-1:797333750312:domain/es4ec2/*"
    }
  ]
}
POLICIES
}