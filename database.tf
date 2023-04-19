# Create WP Database Client SG security group
resource "aws_security_group" "wp-workshop-db-client-sg" {
  name        = "wp-workshop-db-client-sg"
  description = "Security group for clients accessing the WP database"
  vpc_id      = aws_vpc.wp-workshop-vpc.id


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outbound traffic to any IP address on any port"
  }

  tags = {
    Name = "wp-workshop-db-client-sg"
  }
}


# Create WP Database SG security group
resource "aws_security_group" "wp-workshop-db-sg" {
  name        = "wp-workshop-db-sg"
  description = "Security group for the WP database"
  vpc_id      = aws_vpc.wp-workshop-vpc.id

  ingress {
    description     = "Allow inbound traffic on port 3306 from WP Database Client SG"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.wp-workshop-db-client-sg.id]
  }

  egress {
    description = "Allow outbound traffic to any IP address on any port"
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wp-workshop-db-sg"
  }
}




# Create the RDS subnet group
resource "aws_db_subnet_group" "wp-db-subnet-group" {
  name        = "wp-db-subnet-group"
  description = "Database subnet group for RDS"
  subnet_ids  = [aws_subnet.wp-workshop-data-subnet-a.id, aws_subnet.wp-workshop-data-subnet-b.id]

  tags = {
    Name = "WP DB subnet group"
  }
}


# Create the Aurora database cluster
resource "aws_rds_cluster" "wp-rds-cluster" {
  cluster_identifier     = "wp-aurora-cluster-workshop"
  engine                 = "aurora-mysql"
  engine_version         = "5.7.mysql_aurora.2.11.1"
  database_name          = "wpdb"
  master_username        = "wpadmin"
  master_password        = "wpadmin01"
  skip_final_snapshot = true
  db_subnet_group_name   = aws_db_subnet_group.wp-db-subnet-group.name
  vpc_security_group_ids = [aws_security_group.wp-workshop-db-sg.id]
}


# Create RDS DB instance
resource "aws_rds_cluster_instance" "wp-db-cluster-instances" {
  count              = 2
  identifier         = "wp-db-aurora-cluster-workshop-${count.index}"
  cluster_identifier = aws_rds_cluster.wp-rds-cluster.id
  instance_class     = "db.r5.large"
  engine             = aws_rds_cluster.wp-rds-cluster.engine
  engine_version     = aws_rds_cluster.wp-rds-cluster.engine_version
}







