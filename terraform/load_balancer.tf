
resource "aws_lb" "front" {
  name               = var.project_name
  load_balancer_type = "application"
  internal           = false
  ip_address_type    = "ipv4"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public.*.id

  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-lb"
  }
}

resource "aws_lb_listener" "port_80" {
  load_balancer_arn = aws_lb.front.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

#Target Group
resource "aws_lb_target_group" "target_group" {
  name        = var.project_name
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.vpc.id
  health_check {
    path                = "/"
    port                = 8080
    healthy_threshold   = 2
    unhealthy_threshold = 4
    timeout             = 2
    interval            = 30
    matcher             = "200"
  }
}