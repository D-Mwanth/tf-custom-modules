# Get the certificate from AWS ACM
resource "aws_acm_certificate" "this" {
  domain_name = var.domain
  subject_alternative_names = [
    var.additional_acm_domain_name,
  ]
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

#### ACM validation ####
# Hosted zone id is existing if it is needed
data "aws_route53_zone" "hosted_zone" {
  name         = var.domain
  private_zone = false
}

# Verify the acm domain name
resource "aws_route53_record" "domain_verification" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id         = data.aws_route53_zone.hosted_zone.zone_id
  type            = each.value.type
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  allow_overwrite = true
}