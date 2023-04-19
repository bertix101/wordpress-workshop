# Create a VPC
resource "aws_vpc" "wp-workshop-vpc" {
  cidr_block = "192.168.0.0/16"

  tags = {
    Name = "wp-workshop-vpc"
  }
}



# use data source to get all avalablility zones in region
data "aws_availability_zones" "available_zones" {}




# Create 2 public subnets in 2 available zone in the created VPC
resource "aws_subnet" "wp-workshop-public-subnet-a" {
  vpc_id            = aws_vpc.wp-workshop-vpc.id
  availability_zone = data.aws_availability_zones.available_zones.names[0]
  cidr_block        = "192.168.1.0/24"

  tags = {
    Name = "wp-workshop-public-subnet-a"
  }
}

resource "aws_subnet" "wp-workshop-public-subnet-b" {
  vpc_id            = aws_vpc.wp-workshop-vpc.id
  availability_zone = data.aws_availability_zones.available_zones.names[1]
  cidr_block        = "192.168.2.0/24"

  tags = {
    Name = "wp-workshop-public-subnet-b"
  }
}




# Create 2 private (application) subnets in 2 available zone in the created VPC
resource "aws_subnet" "wp-workshop-app-subnet-a" {
  vpc_id            = aws_vpc.wp-workshop-vpc.id
  availability_zone = data.aws_availability_zones.available_zones.names[0]
  cidr_block        = "192.168.3.0/24"

  tags = {
    Name = "wp-workshop-app-subnet-a"
  }
}

resource "aws_subnet" "wp-workshop-app-subnet-b" {
  vpc_id            = aws_vpc.wp-workshop-vpc.id
  availability_zone = data.aws_availability_zones.available_zones.names[1]
  cidr_block        = "192.168.4.0/24"

  tags = {
    Name = "wp-workshop-app-subnet-b"
  }
}



# Create 2 private (database) subnets in 2 available zone in the created VPC
resource "aws_subnet" "wp-workshop-data-subnet-a" {
  vpc_id            = aws_vpc.wp-workshop-vpc.id
  availability_zone = data.aws_availability_zones.available_zones.names[0]
  cidr_block        = "192.168.5.0/24"

  tags = {
    Name = "wp-workshop-data-subnet-a"
  }
}


resource "aws_subnet" "wp-workshop-data-subnet-b" {
  vpc_id            = aws_vpc.wp-workshop-vpc.id
  availability_zone = data.aws_availability_zones.available_zones.names[1]
  cidr_block        = "192.168.6.0/24"

  tags = {
    Name = "wp-workshop-data-subnet-b"
  }
}


# Create an internet gatway and attach to the VPC
resource "aws_internet_gateway" "wp-workshop-igw" {
  vpc_id = aws_vpc.wp-workshop-vpc.id

  tags = {
    Name = "wp-workshop-igw"
  }
}


# create a route table to be associated with public subnet
resource "aws_route_table" "wp-workshop-rt" {
  vpc_id = aws_vpc.wp-workshop-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wp-workshop-igw.id
  }

  tags = {
    Name = "wp-workshop-rt"
  }
}

# associate the created route table with the public subnet
resource "aws_route_table_association" "public_subnet1_association" {
  subnet_id      = aws_subnet.wp-workshop-public-subnet-a.id
  route_table_id = aws_route_table.wp-workshop-rt.id
}

resource "aws_route_table_association" "public_subnet2_association" {
  subnet_id      = aws_subnet.wp-workshop-public-subnet-b.id
  route_table_id = aws_route_table.wp-workshop-rt.id
}



# create elastic ip to be used by the Nat gatway
resource "aws_eip" "wp-workshop-nat-eip-a" {
  vpc = true
}

resource "aws_eip" "wp-workshop-nat-eip-b" {
  vpc = true
}


# create a NAT gatway in public subnet-a
resource "aws_nat_gateway" "wp-workshop-nat-gateway-a" {
  allocation_id = aws_eip.wp-workshop-nat-eip-a.id
  subnet_id     = aws_subnet.wp-workshop-public-subnet-a.id

  tags = {
    Name = "wp-workshop-nat-gatway-a"
  }
}

# create a NAT gatway in public subnet-b
resource "aws_nat_gateway" "wp-workshop-nat-gateway-b" {
  allocation_id = aws_eip.wp-workshop-nat-eip-b.id
  subnet_id     = aws_subnet.wp-workshop-public-subnet-b.id

  tags = {
    Name = "wp-workshop-nat-gatway-b"
  }

}



# create a route table to be associated with NAT gatway in az-a
resource "aws_route_table" "wp-workshop-rt-a" {
  vpc_id = aws_vpc.wp-workshop-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.wp-workshop-nat-gateway-a.id
  }

  tags = {
    Name = "wp-workshop-rt-a"
  }
}


# associate the created route table with the app subnet
resource "aws_route_table_association" "wp-workshop-app-subnet-association-a" {
  subnet_id      = aws_subnet.wp-workshop-app-subnet-a.id
  route_table_id = aws_route_table.wp-workshop-rt-a.id
}

# associate the created route table with the data subnet
resource "aws_route_table_association" "wp-workshop-data-subnet-association-a" {
  subnet_id      = aws_subnet.wp-workshop-data-subnet-a.id
  route_table_id = aws_route_table.wp-workshop-rt-a.id
}



# create a route table to be associated with NAT gatway in az-b
resource "aws_route_table" "wp-workshop-rt-b" {
  vpc_id = aws_vpc.wp-workshop-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.wp-workshop-nat-gateway-b.id
  }

  tags = {
    Name = "wp-workshop-rt-b"
  }
}


# associate the created route table with the app subnet
resource "aws_route_table_association" "wp-workshop-app-subnet-association-b" {
  subnet_id      = aws_subnet.wp-workshop-app-subnet-b.id
  route_table_id = aws_route_table.wp-workshop-rt-b.id
}

# associate the created route table with the data subnet
resource "aws_route_table_association" "wp-workshop-data-subnet-association-b" {
  subnet_id      = aws_subnet.wp-workshop-data-subnet-b.id
  route_table_id = aws_route_table.wp-workshop-rt-b.id
}





