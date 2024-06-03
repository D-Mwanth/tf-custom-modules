variable "db_subnets_ids" {
  description = "Private subnets in which the database is created in"
  type        = list(string)
}

variable "db_sg_id" {
  description = "Security group to attach to database instances"
  type        = string
}

variable "db_subnet_group_name" {
  description = "Name of the database subnet group"
  type        = string
  default     = "database-subnet-group"
}

variable "db_name" {
  description = "Name of the initial database"
  default     = "threetierdb"
  type        = string
}

variable "env" {
  description = "Name of the environment"
  type        = string
}

variable "db_username" {
  description = "database username"
  type        = string
}

variable "db_password" {
  description = "database password"
  type        = string
}
