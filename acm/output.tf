# output variable for acm arn
output "acm_arn" {
  value = aws_acm_certificate.this.arn
}