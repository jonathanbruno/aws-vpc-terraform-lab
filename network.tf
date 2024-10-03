resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "jb-vpc"
  }
}

resource "aws_subnet" "public_subnet-a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "jb-public-subnet-a"
  }
}

resource "aws_subnet" "public_subnet-b" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "jb-public-subnet-b"
  }
}


resource "aws_subnet" "private_subnet-a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "jb-private-subnet-a"
  }
}

resource "aws_subnet" "private_subnet-b" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "jb-private-subnet-b"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "jb-igw"
  }
}

resource "aws_route_table" "public_route_to_igw" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "jb-route-table-public"
  }
}

resource "aws_route_table_association" "rta_public_subnet_a" {
  subnet_id      = aws_subnet.public_subnet-a.id
  route_table_id = aws_route_table.public_route_to_igw.id
}

resource "aws_route_table_association" "rta_public_subnet_b" {
  subnet_id      = aws_subnet.public_subnet-b.id
  route_table_id = aws_route_table.public_route_to_igw.id
}

resource "aws_eip" "nat_eip" {
  domain   = "vpc"

  depends_on = [
    aws_internet_gateway.igw
  ]

  tags = {
    Name = "jb-nat-eip"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  subnet_id = aws_subnet.public_subnet-a.id
  allocation_id = aws_eip.nat_eip.id

  tags = {
    Name = "jb-nat-gateway"
  }
}

resource "aws_route_table" "private_route_to_nat_gateway" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "jb-route-table-private"
  }
}

resource "aws_route_table_association" "rta_private_subnet_a" {
  subnet_id      = aws_subnet.private_subnet-a.id
  route_table_id = aws_route_table.private_route_to_nat_gateway.id
}

resource "aws_route_table_association" "rta_private_subnet_b" {
  subnet_id      = aws_subnet.private_subnet-b.id
  route_table_id = aws_route_table.private_route_to_nat_gateway.id
}

resource "aws_security_group" "public-traffic" {
  name        = "jb-public-traffic"
  description = "Allow inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "jb-public-traffic"
  }
}