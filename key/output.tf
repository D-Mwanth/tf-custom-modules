# Output the name of the AWS key pair to be used for EC2 instances
output "key_name" {
  value = aws_key_pair.client_key.key_name
}