# set version requirements for aws provider
# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 5.0"
#     }
#   }
# }

#### VPC ####
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr_block

  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.env}-main"
  }
}

#### Internet Gateway ####
# create internet gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.env}-igw"
  }
}

#### SUBNETS ####
# Public subnets
resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  # A map of tags to assign to the resources
  tags = {
    Name = "public-subnet-${var.azs[count.index]}"
  }
}

# Private subnets for app_tier
resource "aws_subnet" "apptier" {
  count = length(var.app_subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.app_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  # A map of tags to assign to the resources
  tags = {
    Name = "app-subnet-${var.azs[count.index]}"
  }
}

# Private subnets for database
resource "aws_subnet" "dbtier" {
  count = length(var.db_subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.db_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  # A map of tags to assign to the resources
  tags = {
    Name = "db-subnet-${var.azs[count.index]}"
  }
}

#### NAT-gateway ####
# Create Elastic IP addresses for NAT gateways
resource "aws_eip" "this" {
  count  = length(var.public_subnets)
  domain = "vpc"

  tags = {
    Name = "${var.env}-nat-${var.public_subnets[count.index]}-${var.azs[count.index]}"
  }
}

# Create NAT gateways dynamically in each public subnet
resource "aws_nat_gateway" "this" {
  count = length(var.public_subnets)

  allocation_id = aws_eip.this[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.env}-nat-${var.azs[count.index]}"
  }

  depends_on = [aws_internet_gateway.this]
}

#### ROUTE TABLES ####
# public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.env}-public"
  }
}

# Route tables for App Tier AZ1 and AZ2
resource "aws_route_table" "app_tier" {
  count = length(var.app_subnets)

  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[count.index].id
  }

  tags = {
    Name = "${var.env}-private-${count.index}"
  }
}

# Route table associations for web tier
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Route table associations for App Tier AZ1 and AZ2
resource "aws_route_table_association" "app_tier_association" {
  count = length(var.app_subnets)

  subnet_id      = aws_subnet.apptier[count.index].id
  route_table_id = aws_route_table.app_tier[count.index].id
}