# Fetch the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_iam_instance_profile" "application_instance_profile" {
  name = "jb-instance-profile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_instance" "application" {
  ami = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet-a.id
  security_groups = [aws_security_group.sg-private-application.id]
  iam_instance_profile = aws_iam_instance_profile.application_instance_profile.name

  tags = {
    Name = "jb-instance-a"
  }

  #depends_on = [
  #  aws_lb.jb-load-balancer
  #]

  user_data = file("install_nginx.sh")
}