variable "waf_name" {
  description = "Name of the WAF"
  type        = string
}

variable "alb_arn" {
  description = "ARN of the load balancer to associate the WAF with"
  type        = string
}