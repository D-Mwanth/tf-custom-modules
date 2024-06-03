# Output the cluster endpoint, master username, and password
output "database_credentials" {
  value = {
    endpoint = aws_rds_cluster.aurora-cluster.endpoint
    username = aws_rds_cluster.aurora-cluster.master_username
    password = aws_rds_cluster.aurora-cluster.master_password
  }
}