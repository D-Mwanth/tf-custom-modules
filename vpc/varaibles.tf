variable "env" {
  description = "Enviroment name"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block of a vpc."
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones for subnets."
  type        = list(string)
}

variable "public_subnets" {
  description = "CIDR ranges for public subnets."
  type        = list(string)
}

variable "app_subnets" {
  description = "CIDR ranges for private subnets."
  type        = list(string)
}

variable "db_subnets" {
  description = "CIDR ranges for database subnets."
  type        = list(string)
}