# Get the hosted zone that is existing if it is needed
data "aws_route53_zone" "hosted_zone" {
  name         = var.hosted_zone
  private_zone = false
}

# DNS Record to ALB
resource "aws_route53_record" "website_dns_record" {
  zone_id = data.aws_route53_zone.hosted_zone.id
  name    = var.web_domain_name
  type    = "A"

  alias {
    name                   = var.public_lb_dns_name
    zone_id                = var.public_lb_zone_id
    evaluate_target_health = true
  }
}