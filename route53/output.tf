output "website_dns_record" {
  value = aws_route53_record.website_dns_record[*].fqdn
}