# Create Web ACL
resource "aws_wafv2_web_acl" "this" {
  name  = var.waf_name
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 0

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "webACLVisibilityConfig"
    sampled_requests_enabled   = true
  }

  tags = {
    Name = "${var.waf_name}"
  }
}

# # attach the acl to the loadbalancer
resource "aws_wafv2_web_acl_association" "this" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
  depends_on   = [aws_wafv2_web_acl.this]
}