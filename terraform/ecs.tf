# ============================================================
# ecs.tf — ECS Cluster + Task Definitions + Services
# Innovatech Chile — ISY1101 EP2
# ============================================================

# ==========================================
# 1. ECS CLUSTER
# ==========================================
resource "aws_ecs_cluster" "innovatech_cluster" {
  name = "innovatech-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# ==========================================
# 2. ROL DE PERMISOS (LabRole de AWS Academy)
# ==========================================
data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

data "aws_caller_identity" "current" {}

# ==========================================
# 3. CLOUDWATCH LOG GROUPS
# ==========================================
resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/ecs/innovatech-frontend"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "despachos" {
  name              = "/ecs/innovatech-despachos"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "ventas" {
  name              = "/ecs/innovatech-ventas"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "mysql_despachos" {
  name              = "/ecs/innovatech-mysql-despachos"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "mysql_ventas" {
  name              = "/ecs/innovatech-mysql-ventas"
  retention_in_days = 7
}

# ==========================================
# 4. SECURITY GROUP PARA ECS FARGATE
# ==========================================
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.project_name}-sg-ecs-tasks"
  description = "Security Group para tareas ECS Fargate"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP Frontend desde Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "API Despachos desde VPC"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "API Ventas desde VPC"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "MySQL interno entre contenedores ECS"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Todo el trafico saliente"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-sg-ecs-tasks"
    Project = var.project_name
  }
}

# ==========================================
# 5. TASK DEFINITIONS
# ==========================================

# Frontend
resource "aws_ecs_task_definition" "task_frontend" {
  family                   = "frontend-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = data.aws_iam_role.lab_role.arn
  task_role_arn            = data.aws_iam_role.lab_role.arn

  container_definitions = jsonencode([
    {
      name      = "frontend-container"
      image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com/innovatech-frontend:latest"
      essential = true
      portMappings = [{ containerPort = 80, hostPort = 80, protocol = "tcp" }]
      environment = [
        { name = "VITE_API_URL", value = "http://localhost:8081" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/innovatech-frontend"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "frontend"
        }
      }
    }
  ])
}

# Backend Despachos + MySQL sidecar
resource "aws_ecs_task_definition" "task_despachos" {
  family                   = "despachos-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024" 
  memory                   = "2048"
  execution_role_arn       = data.aws_iam_role.lab_role.arn
  task_role_arn            = data.aws_iam_role.lab_role.arn

  container_definitions = jsonencode([
    {
      name      = "mysql-despachos"
      image     = "mysql:8.0"
      essential = true
      portMappings = [{ containerPort = 3306, hostPort = 3306, protocol = "tcp" }]
      environment = [
        { name = "MYSQL_ROOT_PASSWORD", value = "rootpass123" },
        { name = "MYSQL_DATABASE",      value = "despachos_db" },
        { name = "MYSQL_USER",          value = "despacho_user" },
        { name = "MYSQL_PASSWORD",      value = "despacho_pass123" }
      ]
      healthCheck = {
        command     = ["CMD-SHELL", "mysqladmin ping -h localhost -uroot -prootpass123 || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 5
        startPeriod = 40
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/innovatech-mysql-despachos"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "mysql-despachos"
        }
      }
    },
    {
      name      = "despachos-container"
      image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com/innovatech-backend-despachos:latest"
      essential = true
      portMappings = [{ containerPort = 8081, hostPort = 8081, protocol = "tcp" }]
      environment = [
        { name = "DB_ENDPOINT", value = "127.0.0.1" },
        { name = "DB_PORT",     value = "3306" },
        { name = "DB_NAME",     value = "despachos_db" },
        { name = "DB_USERNAME", value = "despacho_user" },
        { name = "DB_PASSWORD", value = "despacho_pass123" },
        { name = "SPRING_PROFILES_ACTIVE", value = "prod" },
        { name = "SPRING_DATASOURCE_URL", value = "jdbc:mysql://127.0.0.1:3306/despachos_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC" },
        { name = "SPRING_DATASOURCE_USERNAME", value = "despacho_user" },
        { name = "SPRING_DATASOURCE_PASSWORD", value = "despacho_pass123" }
      ]
      dependsOn = [{ containerName = "mysql-despachos", condition = "HEALTHY" }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/innovatech-despachos"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "despachos"
        }
      }
    }
  ])
}

# Backend Ventas + MySQL sidecar
resource "aws_ecs_task_definition" "task_ventas" {
  family                   = "ventas-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = data.aws_iam_role.lab_role.arn
  task_role_arn            = data.aws_iam_role.lab_role.arn

  container_definitions = jsonencode([
    {
      name      = "mysql-ventas"
      image     = "mysql:8.0"
      essential = true
      portMappings = [{ containerPort = 3306, hostPort = 3306, protocol = "tcp" }]
      environment = [
        { name = "MYSQL_ROOT_PASSWORD", value = "rootpass123" },
        { name = "MYSQL_DATABASE",      value = "ventas_db" },
        { name = "MYSQL_USER",          value = "ventas_user" },
        { name = "MYSQL_PASSWORD",      value = "ventas_pass123" }
      ]
      healthCheck = {
        command     = ["CMD-SHELL", "mysqladmin ping -h localhost -uroot -prootpass123 || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 5
        startPeriod = 40
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/innovatech-mysql-ventas"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "mysql-ventas"
        }
      }
    },
    {
      name      = "ventas-container"
      image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com/innovatech-backend-ventas:latest"
      essential = true
      portMappings = [{ containerPort = 8080, hostPort = 8080, protocol = "tcp" }]
      environment = [
        { name = "DB_ENDPOINT", value = "127.0.0.1" },
        { name = "DB_PORT",     value = "3306" },
        { name = "DB_NAME",     value = "ventas_db" },
        { name = "DB_USERNAME", value = "ventas_user" },
        { name = "DB_PASSWORD", value = "ventas_pass123" },
        { name = "SPRING_PROFILES_ACTIVE", value = "prod" },
        { name = "SPRING_DATASOURCE_URL", value = "jdbc:mysql://127.0.0.1:3306/ventas_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC" },
        { name = "SPRING_DATASOURCE_USERNAME", value = "ventas_user" },
        { name = "SPRING_DATASOURCE_PASSWORD", value = "ventas_pass123" }
      ]
      dependsOn = [{ containerName = "mysql-ventas", condition = "HEALTHY" }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/innovatech-ventas"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ventas"
        }
      }
    }
  ])
}

# ==========================================
# 6. ECS SERVICES
# ==========================================
resource "aws_ecs_service" "svc_frontend" {
  name            = "frontend-service"
  cluster         = aws_ecs_cluster.innovatech_cluster.id
  task_definition = aws_ecs_task_definition.task_frontend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public.id]
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }
}

resource "aws_ecs_service" "svc_despachos" {
  name            = "despachos-service"
  cluster         = aws_ecs_cluster.innovatech_cluster.id
  task_definition = aws_ecs_task_definition.task_despachos.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public.id]
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }
}

resource "aws_ecs_service" "svc_ventas" {
  name            = "ventas-service"
  cluster         = aws_ecs_cluster.innovatech_cluster.id
  task_definition = aws_ecs_task_definition.task_ventas.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public.id]
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }
}