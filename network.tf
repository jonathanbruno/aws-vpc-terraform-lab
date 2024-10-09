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

resource "aws_security_group" "sg-public-traffic" {
  name        = "jb-sg-public-traffic"
  description = "Allow inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "jb-sg-public-traffic"
  }
}

resource "aws_security_group" "sg-private-application" {
  name        = "jb-sg-private-application"
  description = "Allow inbound traffic from load balancer and outbound traffic to NAT Gateway"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "jb-sg-private-application"
  }
}

resource "aws_security_group_rule" "sg-public-traffic-ingress-rule-a" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"                # Allowing all protocols, you can specify if needed
  security_group_id = aws_security_group.sg-public-traffic.id
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "sg-public-traffic-egress-rule-a" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"                # Allowing all protocols, you can specify if needed
  security_group_id = aws_security_group.sg-public-traffic.id
  source_security_group_id = aws_security_group.sg-private-application.id
  description       = "Allow outbound traffic to private security group"
}

resource "aws_security_group_rule" "sg-private-application-ingress-rule-a" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"                # Allowing all protocols, you can specify if needed
  security_group_id = aws_security_group.sg-private-application.id
  source_security_group_id = aws_security_group.sg-public-traffic.id
  description       = "Allow inbound traffic from public security group"
}

resource "aws_security_group_rule" "sg-private-application-egress-rule-a" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"                # Allowing all protocols, you can specify if needed
  security_group_id = aws_security_group.sg-private-application.id
  cidr_blocks = ["0.0.0.0/0"]
  description       = "Allow outbound traffic to the internet"
}
