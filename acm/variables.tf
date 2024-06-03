variable "domain" {
  description = "domain name to create a certificate for"
  type        = string
}

variable "additional_acm_domain_name" {
  description = "any additional name to generate a cert for"
  type        = string
}