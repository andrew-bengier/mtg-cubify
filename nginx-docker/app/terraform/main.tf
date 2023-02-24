terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.55.0"
    }
  }

  required_version = ">= 1.0.0"
}

provider "aws" {
  region                   = "us-east-1"
  profile                  = "bnfd-abengier"
  shared_credentials_files = ["~/.aws/credentials"]

  default_tags {
    tags = {
      project     = "nginx-docker"
      startedBy   = "Terraform"
      workspace   = terraform.workspace
      environment = terraform.workspace
    }
  }
}

locals {
    container_definition_name = "bnfd-nginx-docker"
}

resource "aws_ecr_repository" "bnfd_nginx" {
  name = "bnfd_nginx"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecs_task_definition" "bnfd_nginx_ecs_task_definition" {
  family = "service"
  container_definitions = jsonencode([
    {
      name              = locals.container_definition_name
      image             = var.image_full
      memoryReservation = 200
      essential         = true

      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "bnfd_nginx_ecs_service" {
  name                 = "bnfd_nginx-ecs-service"
  cluster              = data.aws_ssm_parameter.parent_ecs_cluster_name.value
  force_new_deployment = true
  desired_count        = 1
  launch_type          = "EC2"
  task_definition      = aws_ecs_task_definition.bnfd_nginx_ecs_task_definition.arn

  load_balancer {
    target_group_arn = data.aws_ssm_parameter.lb_target_group.value
    container_name   = local.container_definition_name
    container_port   = 80
  }
}

output "ecr_repo_worker_endpoint" {
  value = aws_ecr_repository.bnfd_ecr_repo.repository_url
}
