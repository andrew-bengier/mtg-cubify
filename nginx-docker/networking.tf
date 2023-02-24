resource "aws_vpc" "bnfd_vpc" {
  cidr_block           = var.vpc-cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { 
    Name = "${terraform.workspace}-vpc"
  }
}

resource "aws_internet_gateway" "bnfd_internet_gateway" {
    vpc_id = aws_vpc.bnfd_vpc.id

    tags   = {
        Name = "${terraform.workspace}-internet-gateway"
    }
}

resource "aws_subnet" "public_subnets" {
  cidr_block              = element(var.public-subnets, count.index)
  vpc_id                  = aws_vpc.bnfd_vpc.id
  count                   = length(var.public-subnets)
  map_public_ip_on_launch = true

  tags = { 
    Name = "${terraform.workspace}-public-subnet-${count.index}"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.bnfd_vpc.id

  route {
    cidr_block = "0.0.0.0/0" # catch all traffic
    gateway_id = aws_internet_gateway.bnfd_internet_gateway.id
  }

  tags = { 
    Name = "${terraform.workspace}-route-table" 
  }
}

resource "aws_route_table_association" "public_route_table_association" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  count          = length(var.public-subnets)
}

resource "aws_security_group" "load_balancer_security_group" {
  vpc_id = aws_vpc.bnfd_vpc.id
  ingress {
    from_port        = 80
    protocol         = "tcp"
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    protocol         = "-1"
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = { 
    Name = "${terraform.workspace}-lb-security-group" 
  }
}

resource "aws_alb" "load_balancer" {
  name               = "${terraform.workspace}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public_subnets[*].id
  security_groups    = [aws_security_group.load_balancer_security_group.id]

  tags = { 
    Name = "${terraform.workspace}-load-balancer" 
  }
}

resource "aws_alb_target_group" "lb_target_group" {
  name        = "${terraform.workspace}-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.bnfd_vpc.id

  health_check {
    healthy_threshold   = "2"
    interval            = "300"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }

  tags = { 
    Name = "${terraform.workspace}-target-group"
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.load_balancer.id
  port              = 80
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.lb_target_group.id
  }
}

output "load_balancer_ip" {
  value = aws_lb.load_balancer.dns_name
}

