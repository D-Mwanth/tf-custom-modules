output "internet_facing_lb_sg" {
  value = aws_security_group.internet_facing_lb_sg.id
}

output "internal_lb_sg" {
  value = aws_security_group.internal_lb_sg.id
}

output "public_instance_sg" {
  value = aws_security_group.public_instance_sg.id
}

output "private_instances_sg" {
  value = aws_security_group.private_instances_sg.id
}

output "database_sg" {
  value = aws_security_group.database_sg.id
}

output "sysmanager_endpoints_sg" {
  value = aws_security_group.ssm_https.id
}