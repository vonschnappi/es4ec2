output "ssh_security_group_id" {
  value = aws_security_group.ssh_for_ec2_to_view_es_kibana.id
}

output "es_kibana_security_group_id" {
  value = aws_security_group.access_to_es_kibana.id
}

output "es_4_ec2_public_subnet_id" {
  value = aws_subnet.es_4_ec2_public_subnet.id
}

output "es_4_ec2_private_subnet_id1" {
  value = aws_subnet.es_4_ec2_private_subnet1.id
}

output "es_4_ec2_private_subnet_id2" {
  value = aws_subnet.es_4_ec2_private_subnet2.id
}