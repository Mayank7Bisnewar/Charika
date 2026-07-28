terraform {
  required_version = ">= 1.4.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {}

resource "aws_vpc" "charika" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "charika-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.charika.id
  tags = {
    Name = "charika-igw"
  }
}

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.charika.id
  cidr_block              = cidrsubnet(aws_vpc.charika.cidr_block, 8, count.index)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "charika-public-${count.index + 1}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.charika.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "charika-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "ecs" {
  name        = "charika-ecs-sg"
  description = "Allow web traffic to ECS tasks"
  vpc_id      = aws_vpc.charika.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 8000
    to_port     = 8000
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
    Name = "charika-ecs-sg"
  }
}

resource "aws_security_group" "rds" {
  name        = "charika-rds-sg"
  description = "Allow ECS to access PostgreSQL"
  vpc_id      = aws_vpc.charika.id

  ingress {
    description = "Postgres from ECS"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "charika-rds-sg"
  }
}

resource "aws_db_subnet_group" "charika" {
  name       = "charika-db-subnet-group"
  subnet_ids = aws_subnet.public[*].id
  tags = {
    Name = "charika-db-subnet-group"
  }
}

resource "random_password" "db_password" {
  length  = 16
  special = false
}

resource "aws_db_instance" "charika" {
  identifier              = "charika-db"
  allocated_storage       = 20
  engine                  = "postgres"
  engine_version          = "15.4"
  instance_class          = var.db_instance_class
  name                    = var.db_database_name
  username                = var.db_username
  password                = random_password.db_password.result
  db_subnet_group_name    = aws_db_subnet_group.charika.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  skip_final_snapshot     = true
  publicly_accessible     = false
  multi_az                = false
  storage_encrypted       = true
  backup_retention_period = 7
  tags = {
    Name = "charika-db"
  }
}

resource "aws_ecr_repository" "backend" {
  name = "charika-backend"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_secretsmanager_secret" "database_url" {
  name = "charika/DATABASE_URL"
}

resource "aws_secretsmanager_secret_version" "database_url" {
  secret_id     = aws_secretsmanager_secret.database_url.id
  secret_string = jsonencode({
    DATABASE_URL = "postgresql+asyncpg://${var.db_username}:${random_password.db_password.result}@${aws_db_instance.charika.address}:${aws_db_instance.charika.port}/${var.db_database_name}"
  })
}

resource "aws_secretsmanager_secret" "jwt_secret" {
  name = "charika/JWT_SECRET_KEY"
}

resource "aws_secretsmanager_secret_version" "jwt_secret" {
  secret_id     = aws_secretsmanager_secret.jwt_secret.id
  secret_string = jsonencode({ JWT_SECRET_KEY = var.jwt_secret_key })
}

resource "aws_secretsmanager_secret" "google_maps_key" {
  name = "charika/GOOGLE_MAPS_API_KEY"
}

resource "aws_secretsmanager_secret_version" "google_maps_key" {
  secret_id     = aws_secretsmanager_secret.google_maps_key.id
  secret_string = jsonencode({ GOOGLE_MAPS_API_KEY = var.google_maps_api_key })
}

resource "aws_iam_role" "ecs_execution" {
  name = "charika-ecs-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_secrets_policy" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_ecs_cluster" "charika" {
  name = "charika-cluster"
}

resource "aws_cloudwatch_log_group" "charika" {
  name              = "/ecs/charika-backend"
  retention_in_days = 14
}

resource "aws_lb" "charika" {
  name               = "charika-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs.id]
  subnets            = aws_subnet.public[*].id
  tags = {
    Name = "charika-alb"
  }
}

resource "aws_lb_target_group" "charika" {
  name     = "charika-tg"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = aws_vpc.charika.id

  health_check {
    path                = "/"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.charika.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.charika.arn
  }
}

resource "aws_ecs_task_definition" "charika" {
  family                   = "charika-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_execution.arn

  container_definitions = jsonencode([
    {
      name      = "charika-backend"
      image     = "${aws_ecr_repository.backend.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.charika.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "charika"
        }
      }
      secrets = [
        {
          name      = "DATABASE_URL"
          valueFrom = aws_secretsmanager_secret.database_url.arn
        },
        {
          name      = "JWT_SECRET_KEY"
          valueFrom = aws_secretsmanager_secret.jwt_secret.arn
        },
        {
          name      = "GOOGLE_MAPS_API_KEY"
          valueFrom = aws_secretsmanager_secret.google_maps_key.arn
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "charika" {
  name            = "charika-service"
  cluster         = aws_ecs_cluster.charika.id
  task_definition = aws_ecs_task_definition.charika.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = aws_subnet.public[*].id
    security_groups = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.charika.arn
    container_name   = "charika-backend"
    container_port   = 8000
  }

  depends_on = [aws_lb_listener.http]
}
