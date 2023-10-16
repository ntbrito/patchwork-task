locals {
  account_id = data.aws_caller_identity.current.account_id
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.project_name}-cluster"
  configuration {
    execute_command_configuration {
      logging    = "NONE"
    }
  }
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
  tags = {
    Name = var.project_name
  }
}

resource "aws_ecs_cluster_capacity_providers" "cap_providers" {
  cluster_name = aws_ecs_cluster.ecs_cluster.name
  capacity_providers = [
    "FARGATE",
  ]
  default_capacity_provider_strategy {
    base              = 1
    weight            = 50
    capacity_provider = "FARGATE"
  }
}

# Services
resource "aws_ecs_service" "patchwork_srv" {
  name            = var.project_name
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.patchwork_task.arn
  launch_type     = "FARGATE"
  desired_count   = "1"

  enable_execute_command             = true
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name = var.project_name
    container_port = 8080
  }

  network_configuration {
    subnets = aws_subnet.public.*.id
    security_groups = [aws_security_group.webserver.id]
    assign_public_ip = true
  }
}

resource "aws_ecs_task_definition" "patchwork_task" {
  family                   = var.project_name
  requires_compatibilities = ["FARGATE"]

  cpu          = 256
  memory       = 512
  network_mode = "awsvpc"

  task_role_arn      = aws_iam_role.ecs_role.arn
  execution_role_arn = aws_iam_role.ecs_role.arn

  container_definitions =<<DEFINITION
  [
    {
      "name": "patchwork",
      "image": "${local.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/patchwork/webapp:latest",
      "cpu": 256,
      "memory": 512,
      "portMappings": [{
        "containerPort": 8080,
        "hostPort": 8080
      }],

      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/patchwork",
          "awslogs-region": "eu-west-2",
          "awslogs-create-group": "true",
          "awslogs-stream-prefix": "webapp"
        }
      }
    }
  ]
  DEFINITION

  runtime_platform {
    operating_system_family  = "LINUX"
    cpu_architecture         = "X86_64"
  }
}