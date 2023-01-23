resource "aws_lb" "ecs_application_lb" {
  name               = "ecs-application-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.ecs_public_subnet[*].id
  security_groups    = [aws_security_group.ecs_lb_sg.id]

  # to store access logs in s3
  access_logs {
    bucket   = data.aws_s3_bucket.tfstatebucket.bucket
    prefix   = "ecs-logs-alb-"
    enabled  = true
  }

  tags = {
    Name = "ecs-application-lb"
  }
}

resource "aws_lb_listener" "ecs_lb_listener" {
  load_balancer_arn = aws_lb.ecs_application_lb.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_lb_tg_containers.id
  }
}

# Target Group to relate the lb to the containers
resource "aws_lb_target_group" "ecs_lb_tg_containers" {
  name        = "ecs-lb-tg-containers"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.ecs_vpc.id

  health_check {
    healthy_threshold   = "3"
    interval            = "300"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }

  tags = {
    Name = "ecs_lb-tg-containers"
  }
}



resource "aws_security_group" "ecs_lb_sg" {
  vpc_id = aws_vpc.ecs_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ecs-lb-sg"
  }
}