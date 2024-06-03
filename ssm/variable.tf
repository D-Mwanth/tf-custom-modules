variable "region" {
  description = "Region where the infrastructure is deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where the VPC endpoints will be created"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID of the VPC where the endpoints will be deployed"
  type        = string
}

variable "security_group_id" {
  description = "ID of the security group to associate with the VPC endpoints"
  type        = string
}
