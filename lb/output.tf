# Output variables
output "target_group_arn" {
  description = "The ARN of the target group associated with the load balancer"
  value       = aws_lb_target_group.lb_target_group.arn
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.this.dns_name
}

output "lb_zone_id" {
  description = "The zone ID of the load balancer"
  value       = var.internal ? null : aws_lb.this.zone_id
}

output "lb_arn" {
  description = "The ARN of the load balancer (internet-facing only)"
  value       = var.internal ? null : aws_lb.this.arn
}

output "lb_listener_arn" {
  description = "The ARN of the load balancer listener (internet-facing only)"
  value       = var.internal ? null : aws_lb_listener.this[0].arn
}
