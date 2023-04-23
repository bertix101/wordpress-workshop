# Create WP EFS Client security group
resource "aws_security_group" "wp-workshop-efs-client-sg" {
  name        = "wp-workshop-efs-client-sg"
  description = "Security group for clients accessing the WP files system"
  vpc_id      = aws_vpc.wp-workshop-vpc.id


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outbound traffic to any IP address on any port"
  }

  tags = {
    Name = "wp-workshop-efs-client-sg"
  }
}


# Create WP EFS security group
resource "aws_security_group" "wp-workshop-efs-sg" {
  name        = "wp-workshop-efs-sg"
  description = "Security group for the WP file system"
  vpc_id      = aws_vpc.wp-workshop-vpc.id

  ingress {
    description     = "Allow inbound traffic on port 2049 from WP EFS Client SG"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.wp-workshop-efs-client-sg.id]
  }

  egress {
    description = "Allow outbound traffic to any IP address on any port"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wp-workshop-efs-sg"
  }
}



# Create the EFS filesystem
resource "aws_efs_file_system" "wp-workshop-efs" {
  creation_token = "wp-workshop-efs"

  tags = {
    Name = "wp-workshop-EFS"
  }
}


# Mount the EFS filesystem in the first subnet
resource "aws_efs_mount_target" "wp-workshop-efs-mount-1" {
  file_system_id = aws_efs_file_system.wp-workshop-efs.id
  subnet_id      = aws_subnet.wp-workshop-data-subnet-a.id

  security_groups = [
    aws_security_group.wp-workshop-efs-client-sg.id,
    aws_security_group.wp-workshop-efs-sg.id,
  ]
}


# Mount the EFS filesystem in the second subnet
resource "aws_efs_mount_target" "wp-workshop-efs-mount-2" {
  file_system_id = aws_efs_file_system.wp-workshop-efs.id
  subnet_id      = aws_subnet.wp-workshop-data-subnet-b.id

  security_groups = [
    aws_security_group.wp-workshop-efs-client-sg.id,
    aws_security_group.wp-workshop-efs-sg.id,
  ]
}
