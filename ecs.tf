#Defining the ecs Task
resource "aws_ecs_task_definition" "ecs_task1" {

  family                   = "ecs-task1"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  container_definitions    = <<DEFINITION
  [
    {
      "name": "container-task1",
      "image": "636898878894.dkr.ecr.us-east-1.amazonaws.com/dockerrepo-1:latest",
      "essential": true,
      "cpu": 256,
      "memory": 512,
      "networkMode": "awsvpc",
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80
        }
      ]
    }
  ]
  DEFINITION
}

#Creating the Cluster Resource
resource "aws_ecs_cluster" "ecs_cluster1" {
  name = "ecs-cluster1"
}

#Creating the service
resource "aws_ecs_service" "ecs_service1" {
  name            = "ecs-service1"
  cluster         = aws_ecs_cluster.ecs_cluster1.id
  task_definition = aws_ecs_task_definition.ecs_task1.arn
  launch_type     = "FARGATE"
  scheduling_strategy = "REPLICA"
  desired_count   = 1

  network_configuration {
    subnets          = aws_subnet.ecs_private_subnet[*].id
    assign_public_ip = false
    security_groups = [aws_security_group.ecs_service_sg1.id,
    aws_security_group.ecs_lb_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_lb_tg_containers.arn
    container_name   = "container-task1"
    container_port   = 80
  }
}


resource "aws_security_group" "ecs_service_sg1" {
  name        = "ecs-service-sg1"
  vpc_id      = aws_vpc.ecs_vpc.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    # cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.ecs_lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_HTTP"
  }
}