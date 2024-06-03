# Create target group
resource "aws_lb_target_group" "lb_target_group" {
  name        = "${var.lb_name}-tg"
  target_type = "instance"
  port        = var.instance_tg_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    interval            = 300
    path                = "/"
    timeout             = 60
    matcher             = 200
    healthy_threshold   = 2
    unhealthy_threshold = 5
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create load balancer
resource "aws_lb" "this" {
  name               = var.lb_name
  load_balancer_type = var.lbtype
  internal           = var.internal
  subnets            = var.subnets
  security_groups    = [var.security_group]

  tags = {
    Name = var.lb_name
  }
}

# Create HTTP listener for internal load balancer
resource "aws_lb_listener" "http_listener" {
  count             = var.internal ? 1 : 0
  load_balancer_arn = aws_lb.this.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}

# Create HTTPS listener for internet-facing load balancer
resource "aws_lb_listener" "this" {
  count             = var.internal ? 0 : 1 # Only create for internet-facing LB
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}

# Create HTTP to HTTPS redirect listener for internet-facing load balancer
resource "aws_lb_listener" "http_redirect" {
  count             = var.internal ? 0 : 1 # Only create for internet-facing LB
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
