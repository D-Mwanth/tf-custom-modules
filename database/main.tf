# Create database subnet group
resource "aws_db_subnet_group" "db-subnet-group" {
  name       = var.db_subnet_group_name
  subnet_ids = var.db_subnets_ids
}

# Create Aurora MySQL cluster
resource "aws_rds_cluster" "aurora-cluster" {
  cluster_identifier      = "${var.env}-aurora-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "5.7.mysql_aurora.2.11.5"
  master_username         = var.db_username
  master_password         = var.db_password
  database_name           = var.db_name
  backup_retention_period = 7 # Retain backups for 7 days
  preferred_backup_window = "07:00-09:00"
  db_subnet_group_name    = aws_db_subnet_group.db-subnet-group.name
  vpc_security_group_ids  = [var.db_sg_id]
  skip_final_snapshot     = true

  tags = {
    Name = "${var.env}-aurora-cluster"
  }
}

# Create primary Aurora MySQL instance (write replica)
resource "aws_rds_cluster_instance" "aurora-primary-instance" {
  identifier          = "${var.env}-aurora-primary-instance"
  cluster_identifier  = aws_rds_cluster.aurora-cluster.id
  instance_class      = "db.t3.medium"
  engine              = aws_rds_cluster.aurora-cluster.engine
  engine_version      = aws_rds_cluster.aurora-cluster.engine_version
  publicly_accessible = false

  tags = {
    Name = "${var.env}-aurora-primary-instance"
  }

  depends_on = [aws_rds_cluster.aurora-cluster]
}

# Create replica Aurora MySQL instance (read replica)
resource "aws_rds_cluster_instance" "aurora-replica-instance" {
  count               = 1 # Create one read replica
  identifier          = "${var.env}-aurora-replica-instance-${count.index + 1}"
  cluster_identifier  = aws_rds_cluster.aurora-cluster.id
  instance_class      = "db.t3.medium"
  engine              = aws_rds_cluster.aurora-cluster.engine
  engine_version      = aws_rds_cluster.aurora-cluster.engine_version
  publicly_accessible = false

  tags = {
    Name = "${var.env}-aurora-replica-instance-${count.index + 1}"
  }

  depends_on = [aws_rds_cluster.aurora-cluster]
}