resource "aws_vpc" "es4ec2vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "igwes4ec2vpc" {
  vpc_id = aws_vpc.es4ec2vpc.id

  tags = {
    Name = "igwes4ec2vpc"
  }
}

resource "aws_eip" "nat_gw_ip" {
  vpc = true
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat_gw_ip.id
  subnet_id     = aws_subnet.es_4_ec2_public_subnet.id

  tags = {
    Name = "nat_gateway_for_lambda"
  }
}

resource "aws_route_table" "route_tbl_internet_access_for_ec2" {
  vpc_id = aws_vpc.es4ec2vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igwes4ec2vpc.id
  }

   tags = {
    Name = "public_route_table"
  }
}

resource "aws_route_table" "route_tbl_internet_access_for_lambda" {
  vpc_id = aws_vpc.es4ec2vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.gw.id
  }

  tags = {
    Name = "private_route_table_with_nat_gw"
  }
}

resource "aws_subnet" "es_4_ec2_public_subnet" {
  vpc_id     = aws_vpc.es4ec2vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "es_4_ec2_public_subnet"
  }
}

resource "aws_subnet" "es_4_ec2_private_subnet1" {
  vpc_id     = aws_vpc.es4ec2vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "es_4_ec2_private_subnet"
  }
}

resource "aws_subnet" "es_4_ec2_private_subnet2" {
  vpc_id     = aws_vpc.es4ec2vpc.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "es_4_ec2_private_subnet"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.es_4_ec2_public_subnet.id
  route_table_id = aws_route_table.route_tbl_internet_access_for_ec2.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.es_4_ec2_private_subnet1.id
  route_table_id = aws_route_table.route_tbl_internet_access_for_lambda.id
}

resource "aws_security_group" "ssh_for_ec2_to_view_es_kibana" {
  name        = "ssh_for_ec2_to_view_es_kibana"
  description = "Allows ssh access to the ec2 that is used for ssh tunneling in order to view es4ec2 kibana"
  vpc_id      = aws_vpc.es4ec2vpc.id

  ingress {
    description = "allow ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "ssh_for_ec2_to_view_es_kibana"
  }
}

resource "aws_security_group" "access_to_es_kibana" {
  name        = "access_to_es_kibana"
  description = "Allows lambda and ec2 to access es and kibana"
  vpc_id      = aws_vpc.es4ec2vpc.id

  ingress {
    description     = "allow access to port 9200 to query es"
    from_port       = 9200
    to_port         = 9200
    protocol        = "tcp"
    security_groups = [aws_security_group.ssh_for_ec2_to_view_es_kibana.id]
  }

  ingress {
    description     = "allow 443 to ssh tunnel to kibana"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.ssh_for_ec2_to_view_es_kibana.id]
  }

  ingress {
    description     = "allow 5601 to view kibana"
    from_port       = 5601
    to_port         = 5601
    protocol        = "tcp"
    security_groups = [aws_security_group.ssh_for_ec2_to_view_es_kibana.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "access_to_es_kibana"
  }
}