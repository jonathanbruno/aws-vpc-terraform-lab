resource "aws_lb" "jb-load-balancer" {
  name               = "jb-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg-public-traffic.id]
  subnets            = [
    aws_subnet.public_subnet-a.id,
    aws_subnet.public_subnet-b.id
  ]

  #enable_deletion_protection = true

  tags = {
    Name = "jb-load-balancer"
  }
}

resource "aws_lb_target_group" "jb-target-group" {
  name     = "jb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}


resource "aws_lb_listener" "jb-listener" {
  load_balancer_arn = aws_lb.jb-load-balancer.arn
  port              = "80"
  protocol          = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jb-target-group.arn
  }
}