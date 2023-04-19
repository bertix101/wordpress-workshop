# Create WP memory cached Client SG security group
resource "aws_security_group" "wp-workshop-cache-client-sg" {
  name        = "wp-workshop-cache-client-sg"
  description = "Security group for clients accessing the WP memory cahe"
  vpc_id      = aws_vpc.wp-workshop-vpc.id


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outbound traffic to any IP address on any port"
  }

  tags = {
    Name = "wp-workshop-cache-client-sg"
  }
}


# Create WP memory cache SG security group
resource "aws_security_group" "wp-workshop-cache-sg" {
  name        = "wp-workshop-cache-sg"
  description = "Security group for the WP memory cache"
  vpc_id      = aws_vpc.wp-workshop-vpc.id

  ingress {
    description     = "Allow inbound traffic on port 11211 from WP cache Client SG"
    from_port       = 11211
    to_port         = 11211
    protocol        = "tcp"
    security_groups = [aws_security_group.wp-workshop-cache-client-sg.id]
  }

  egress {
    description = "Allow outbound traffic to any IP address on any port"
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wp-workshop-cache-sg"
  }
}

# Create the Memory Cache subnet group
resource "aws_elasticache_subnet_group" "wp-cache-subnet-group" {
  name        = "wp-cache-subnet-group"
  description = "Subnet group used by Elasticache"
  subnet_ids  = [aws_subnet.wp-workshop-data-subnet-a.id, aws_subnet.wp-workshop-data-subnet-b.id]

  tags = {
    Name = "WP MemCache subnet group"
  }
}



# Create an ElastiCache Memcached instance

resource "aws_elasticache_cluster" "wp-workshop-cache-cluster" {
  cluster_id           = "wp-workshop-memcache-cluster"
  subnet_group_name    = aws_elasticache_subnet_group.wp-cache-subnet-group.name
  security_group_ids   = [aws_security_group.wp-workshop-cache-sg.id]
  engine               = "memcached"
  node_type            = "cache.t2.small"
  num_cache_nodes      = 1
  parameter_group_name = "default.memcached1.6"
  port                 = 11211

  tags = {
    Name = "wp-workshop-Memcache-cluster"
  }
}