# security group for public load balancer
resource "aws_security_group" "internet_facing_lb_sg" {
  name        = "alb-security-group"
  description = "enable http/https access on port 80/443"
  vpc_id      = var.vpc_id

  ingress {
    description = "http access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "https access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "internet-facing-lb-sg"
  }
}

# Security group for internal load balancer: allow http traffic from public instance security group
resource "aws_security_group" "internal_lb_sg" {
  name        = "internal-alb-security-group"
  description = "Allow traffic from the internal load balancer to instances on port 4000"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP access from internal load balancer"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.public_instance_sg.id] // Allow traffic from the public instance security group
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "internal-alb-sg"
  }
}

# Security group for web-tier instance (public instance)
resource "aws_security_group" "public_instance_sg" {
  name        = "public-instance-sg"
  description = "enable http/https access on port 80 for elb sg"
  vpc_id      = var.vpc_id

  // inbound rule to allow HTTP traffic from the internet-facing load balancer security group
  ingress {
    description     = "http access"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.internet_facing_lb_sg.id]
  }

  # Ibound rule to allow ssh traffic from own Ip
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // Replace 'your_ip_address' with your actual IP
  }

  # Allow traffic to all destinations
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public-instance-sg"
  }
}

# Security group for app-tier instance (private instance)
resource "aws_security_group" "private_instances_sg" {
  name        = "private-instances-sg"
  description = "Security group for the app tier"
  vpc_id      = var.vpc_id

  // Allow TCP traffic on port 4000 from the internal load balancer security group
  ingress {
    description     = "http access"
    from_port       = 4000
    to_port         = 4000
    protocol        = "tcp"
    security_groups = [aws_security_group.internal_lb_sg.id]
  }

  tags = {
    Name = "private-instances-sg"
  }

  # Allow traffic to all destinations
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# create security group for the private database instance
resource "aws_security_group" "database_sg" {
  name        = "database-sg"
  description = "Security group for the private database instances"
  vpc_id      = var.vpc_id

  ingress {
    description     = "mysql access"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.private_instances_sg.id]
  }

  tags = {
    Name = "database-sg"
  }
}

# security group for ssm_endpoint to allow ssm traffic
resource "aws_security_group" "ssm_https" {
  name        = "allow-ssm"
  description = "Allow SSM traffic through vpc endpoints"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.app_subnets_cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ssm-security-group"
  }
}