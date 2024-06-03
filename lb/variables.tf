# Variables declaration
variable "vpc_id" {
  description = "VPC ID where the load balancer will be deployed"
  type        = string
}

variable "lb_name" {
  description = "Name of the load balancer"
  type        = string
}

variable "security_group" {
  description = "Security group for the load balancer"
  type        = string
}

variable "internal" {
  description = "Whether the load balancer is internal (true) or internet-facing (false)"
  type        = bool
  default     = false
}

variable "lbtype" {
  description = "Type of load balancer (e.g., application, network)"
  type        = string
  default     = "application"
}

variable "subnets" {
  description = "List of subnet IDs in which the load balancer will be deployed"
  type        = list(string)
}

variable "instance_tg_port" {
  description = "Port on the target instances that the load balancer will route traffic to"
  type        = number
  default     = 80
}

variable "listener_port" {
  description = "Port on the load balancer listener"
  type        = number
  default     = 80
}

variable "listener_protocol" {
  description = "Protocol used by the load balancer listener (e.g., HTTP, HTTPS)"
  type        = string
  default     = "HTTP"
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS listener (only for internet-facing LB)"
  type        = string
  default     = null
}