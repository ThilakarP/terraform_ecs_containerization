#Create VPC resource
resource "aws_vpc" "ecs_vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"
  tags = {
    Name = "vpc-ecs-containerization-project"
  }
}

#Public Subnets
resource "aws_subnet" "ecs_public_subnet" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.ecs_vpc.id
  cidr_block              = element(var.public_subnets[*], count.index)
  availability_zone       = element(var.azs[*], count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

#Private Subnets
resource "aws_subnet" "ecs_private_subnet" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.ecs_vpc.id
  cidr_block        = element(var.private_subnets[*], count.index)
  availability_zone = element(var.azs[*], count.index)

  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

#IGw for the VPC
resource "aws_internet_gateway" "ecs_igw" {
  vpc_id = aws_vpc.ecs_vpc.id

  tags = {
    "Name" = "igw-ecs-containerization"
  }

}

#Route table for the Internet Gateway
resource "aws_route_table" "ecs_rt" {
  vpc_id = aws_vpc.ecs_vpc.id
  route {
    gateway_id = aws_internet_gateway.ecs_igw.id
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    "Name" = "ecs-routetable"
  }
}

# Associate the route table to public subnets
resource "aws_route_table_association" "ecs_rt1_associate" {
  count          = length(var.public_subnets)
  route_table_id = aws_route_table.ecs_rt.id
  subnet_id      = element(aws_subnet.ecs_public_subnet[*].id, count.index)
}


resource "aws_eip" "ecs_eip" {
  vpc = true

  tags = {
    Name = "eip-for-natgateway"
  }
}


resource "aws_nat_gateway" "ecs_nat_gateway" {
  # Allocating the Elastic IP to the NAT Gateway!
  allocation_id = aws_eip.ecs_eip.id
  # placing the NAT gateway in public Subnet!
  subnet_id = element(aws_subnet.ecs_public_subnet[*].id, 0)

  tags = {
    Name = "ecs-nat-gateway"
  }

}

resource "aws_route_table" "ecs_nat_rt" {
  vpc_id = aws_vpc.ecs_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ecs_nat_gateway.id
  }

  tags = {
    Name = "ecs-nat-routetable"
  }

}

resource "aws_route_table_association" "ecs_nat_rt_associate" {
  count          = length(var.private_subnets)
  subnet_id      = element(aws_subnet.ecs_private_subnet[*].id, count.index)
  route_table_id = aws_route_table.ecs_nat_rt.id

}
  