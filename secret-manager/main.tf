# Create a secret in AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_secret" {
  name        = var.secret_name
  description = "Secret for accessing the database"
}

resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username     = var.db_username
    password     = var.db_password
    endpoint     = var.db_endpoint
    app_database = var.app_database
  })
}

# I did not encrypt secrets so are stored in cloud as plane text
# if you working on a production application, you should encrypt them to enhance security on cloud