data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  owners = ["amazon"]
}

resource "aws_iam_policy" "es4ec2_ec2_instance_policy" {
  name        = var.ec2_instance_policy_name
  path        = "/"
  description = var.ec2_instance_policy_description

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
         "Action":[
            "es:*"
         ],
         "Effect":"Allow",
         "Resource":"*"
      }
  ]
}
EOF
}

resource "aws_iam_role" "iam_for_ec2_access_kibana" {
  name = var.ec2_instance_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "iam_for_ec2_access_kibana" {
  name = "iam_for_ec2_access_kibana"
  role = aws_iam_role.iam_for_ec2_access_kibana.name
}


resource "aws_iam_role_policy_attachment" "attach_es4ec2_policy_to_role" {
  role       = aws_iam_role.iam_for_ec2_access_kibana.name
  policy_arn = aws_iam_policy.es4ec2_ec2_instance_policy.arn
}

resource "aws_instance" "kibana_access" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t2.small"
  vpc_security_group_ids      = var.kibana_access_security_group
  subnet_id                   = var.kibana_access_subnet[0]
  key_name                    = "ansible"
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.iam_for_ec2_access_kibana.name

  tags = {
    Name = "kibana_access_instance"
  }
}