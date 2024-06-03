# create a key pair
resource "aws_key_pair" "client_key" {
  key_name   = "client_key"
  public_key = file(var.public_key)
}