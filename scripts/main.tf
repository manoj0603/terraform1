terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.95.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "ap-south-1"
}
resource "aws_vpc" "VPC" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "my-vpc"
  }
}

resource "aws_subnet" "public-sub" {
  vpc_id     = aws_vpc.VPC.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "public-sub"
  }
}

resource "aws_subnet" "private-sub" {
  vpc_id     = aws_vpc.VPC.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "private-sub"
  }
}

resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.example.id

  route = []

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table" "pvt-rt" {
  vpc_id = aws_vpc.example.id

  route = []

  tags = {
    Name = "private-rt"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "internetGW"
  }
}

resource "aws_eip" "eip" {
  instance = aws_instance.web.id
  domain   = "vpc"
}

resource "aws_nat_gateway" "NAT" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public-sub.id

  tags = {
    Name = "NAT-GW"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}