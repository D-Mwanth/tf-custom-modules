# creat iam role for ec2 user
resource "aws_iam_role" "ec2_role" {
  name               = "ec2-instance-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

#### CREATE AND ATTACH POLICIES ####
# create policy to allow access to secret manager
resource "aws_iam_policy" "secrets_manager_access_policy" {
  name        = "SecretsManagerAccessPolicy"
  description = "Allows access to a specific secret in AWS Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = "secretsmanager:GetSecretValue",
      Resource = "*" //"arn:aws:secretsmanager:${var.region}:123456789012:secret:${var.secret_name}"  // Here we are allowing access to any secret we have but you can narrow down to specific secret using commented value
    }]
  })
}

### Policy to describe loadbalancer
resource "aws_iam_policy" "elb_describe_policy" {
  name        = "ELBDescribePolicy"
  description = "Allows describing Elastic Load Balancers"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeTags" # This action is needed to describe tags on the load balancers
        ]
        Resource = "*"
      }
    ]
  })
}


# attach policy to allow user to access secrets manager
resource "aws_iam_role_policy_attachment" "sm_access_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.secrets_manager_access_policy.arn
}

# allow aws s3 read permission
resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# Attach the SSM managed policy to the IAM role
resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "elb_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.elb_describe_policy.arn
}

####### create ec2 isntance profile #######
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "iam_instance_profile"
  role = aws_iam_role.ec2_role.name
}