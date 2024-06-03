# Creates VPC endpoints for AWS Systems Manager (SSM) services
resource "aws_vpc_endpoint" "ssm_endpoint" {
  for_each = local.services
  vpc_id   = var.vpc_id

  service_name        = each.value.name
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [var.security_group_id]
  private_dns_enabled = true
  ip_address_type     = "ipv4"
  subnet_ids          = var.subnet_ids
}