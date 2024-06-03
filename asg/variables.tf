variable "tier_name" {
  description = "Name of the tier to create instances"
  type        = string
}
# variable "ami" {}
variable "instance_type" {
  description = "Instance type for the EC2 instances"
  default     = "t2.micro"
  type        = string
}

variable "key_name" {
  description = "Name of the EC2 key pair to associate with the instance"
  type        = string

}

variable "max_size" {
  description = "Maximum number of instances the Auto Scaling group can scale out to"
  type        = number
  default     = 8
}

variable "min_size" {
  description = "Minimum number of instances autoscalling group can scale down to"
  type        = number
  default     = 2
}

variable "desired_cap" {
  description = "Desired number of instances in the Auto Scaling group"
  type        = number
  default     = 2
}

variable "asg_health_check_type" {
  description = "Type of health check to use for Auto Scaling group instances"
  type        = string
  default     = "ELB"
}

variable "subnet_ids" {
  description = "List of subnet IDs in which to launch EC2 instances"
  type        = list(string)
}

variable "tier_instance_sg" {
  description = "Security group associtated with the instance"
  type        = string
}

variable "lb_tg_arn" {}
variable "iam_instance_profile" {
  description = "IAM instance profile to associate with the instance"
  type        = string
}

variable "user_data" {
  description = "User data to provide when launching the instance"
  type        = string
}