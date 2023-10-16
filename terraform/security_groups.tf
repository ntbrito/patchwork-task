resource "aws_security_group" "alb" {
  description = "Security group allowing access to the alb"
  name        = "${var.project_name}-alb-sg"
  vpc_id      = aws_vpc.vpc.id
  tags = {
    Name = "ALB Security Group"
  }
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type = "ingress"
  security_group_id = aws_security_group.alb.id
  from_port = "80"
  to_port = "80"
  protocol = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "allow_alb_out" {
  type              = "egress"
  security_group_id = aws_security_group.alb.id
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group" "webserver" {
  description = "Security group allowing access to the webserver"
  name        = "${var.project_name}-web"
  vpc_id      = aws_vpc.vpc.id
  tags = {
    Name = "Web Security Group"
  }
}

resource "aws_security_group_rule" "allow_alb_to_web_8080" {
  type = "ingress"
  security_group_id = aws_security_group.webserver.id
  from_port = "8080"
  to_port = "8080"
  protocol = "tcp"
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "allow_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.webserver.id
  from_port        = "0"
  to_port          = "0"
  protocol         = "-1"
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}
