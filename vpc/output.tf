# output the vpc id
output "vpc_id" {
  value       = aws_vpc.this.id
  description = "VPC id"
}

# output the public subnets
output "web_subnets_ids" {
  value = aws_subnet.public[*].id
}

# output application tier private subnets
output "app_subnets_ids" {
  value = aws_subnet.apptier[*].id
}

# output database tier private subnets
output "db_subnets_ids" {
  value = aws_subnet.dbtier[*].id
}