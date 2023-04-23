# Create the WP load balancer security group
resource "aws_security_group" "wp-workshop-lb-sg" {
  name        = "wp-workshop-lb-sg"
  description = "Security group for the WP load balancer"
  vpc_id      = aws_vpc.wp-workshop-vpc.id

  ingress {
    description = "Allow inbound traffic on port 80 from WP Database Client SG"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wp-workshop-lb-sg"
  }
}

# Create the application load balancer
resource "aws_lb" "wp-workshop-lb" {
  name               = "wp-workshop-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.wp-workshop-lb-sg.id]
  subnets            = ["${aws_subnet.wp-workshop-public-subnet-a.id}", "${aws_subnet.wp-workshop-public-subnet-b.id}"]

  enable_deletion_protection = false

  #access_logs {
  #  bucket  = aws_s3_bucket.lb_logs.id
  #  prefix  = "wp-lb"
  #  enabled = true
  #}

  tags = {
    Environment = "dev"
  }
  depends_on = [aws_security_group.wp-workshop-lb-sg]
}


# Create the target Group for use with Load Balancer resources
resource "aws_lb_target_group" "wp-workshop-lb-target-group" {
  name     = "wp-workshop-lb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.wp-workshop-vpc.id
}



# Provides a Load Balancer Listener resource
resource "aws_lb_listener" "wp-workshop-lb-listener" {
  load_balancer_arn = aws_lb.wp-workshop-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wp-workshop-lb-target-group.arn
  }
}









