# ==========================================

# 1. ECS CLUSTER

# ==========================================

resource "aws_ecs_cluster" "innovatech_cluster" {

 name = "innovatech-cluster"

}



# ==========================================

# 2. ROL DE PERMISOS PARA DESCARGAR IMÁGENES

# ==========================================

resource "aws_iam_role" "ecs_execution_role" {

 name = "ecs_execution_role_innovatech"

 assume_role_policy = jsonencode({

  Version = "2012-10-17"

  Statement = [{

   Action = "sts:AssumeRole"

   Effect = "Allow"

   Principal = { Service = "ecs-tasks.amazonaws.com" }

  }]

 })

}



resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {

 role    = aws_iam_role.ecs_execution_role.name

 policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"

}



# ==========================================

# 3. TASK DEFINITIONS (Tus Contenedores)

# ==========================================

resource "aws_ecs_task_definition" "task_ventas" {

 family          = "ventas-task"

 network_mode       = "awsvpc"

 requires_compatibilities = ["FARGATE"]

 cpu           = "256"

 memory          = "512"

 execution_role_arn    = aws_iam_role.ecs_execution_role.arn



 container_definitions = jsonencode([{

  name   = "ventas-container"

  image   = "TU_CUENTA_AWS.dkr.ecr.us-east-1.amazonaws.com/innovatech-backend-ventas:latest" # <-- REEMPLAZAR

  essential = true

  portMappings = [{ containerPort = 8080, hostPort = 8080 }]

 }])

}



resource "aws_ecs_task_definition" "task_despachos" {

 family          = "despachos-task"

 network_mode       = "awsvpc"

 requires_compatibilities = ["FARGATE"]

 cpu           = "256"

 memory          = "512"

 execution_role_arn    = aws_iam_role.ecs_execution_role.arn



 container_definitions = jsonencode([{

  name   = "despachos-container"

  image   = "TU_CUENTA_AWS.dkr.ecr.us-east-1.amazonaws.com/innovatech-backend-despachos:latest" # <-- REEMPLAZAR

  essential = true

  portMappings = [{ containerPort = 8081, hostPort = 8081 }] 

 }])

}



resource "aws_ecs_task_definition" "task_frontend" {

 family          = "frontend-task"

 network_mode       = "awsvpc"

 requires_compatibilities = ["FARGATE"]

 cpu           = "256"

 memory          = "512"

 execution_role_arn    = aws_iam_role.ecs_execution_role.arn



 container_definitions = jsonencode([{

  name   = "frontend-container"

  image   = "TU_CUENTA_AWS.dkr.ecr.us-east-1.amazonaws.com/innovatech-frontend:latest" # <-- REEMPLAZAR

  essential = true

  portMappings = [{ containerPort = 80, hostPort = 80 }]

 }])

}



# ==========================================

# 4. SERVICIOS (Mantienen los contenedores vivos en la VPC)

# ==========================================

resource "aws_ecs_service" "svc_ventas" {

 name      = "ventas-service"

 cluster     = aws_ecs_cluster.innovatech_cluster.id

 task_definition = aws_ecs_task_definition.task_ventas.arn

 desired_count  = 1

 launch_type   = "FARGATE"



 network_configuration {

  subnets     = [aws_subnet.public.id] 

  security_groups = [aws_security_group.backend.id] # <- Protegido por el SG de Backend

  assign_public_ip = true

 }

}



resource "aws_ecs_service" "svc_despachos" {

 name      = "despachos-service"

 cluster     = aws_ecs_cluster.innovatech_cluster.id

 task_definition = aws_ecs_task_definition.task_despachos.arn

 desired_count  = 1

 launch_type   = "FARGATE"



 network_configuration {

  subnets     = [aws_subnet.public.id] 

  security_groups = [aws_security_group.backend.id] # <- Protegido por el SG de Backend

  assign_public_ip = true

 }

}



resource "aws_ecs_service" "svc_frontend" {

 name      = "frontend-service"

 cluster     = aws_ecs_cluster.innovatech_cluster.id

 task_definition = aws_ecs_task_definition.task_frontend.arn

 desired_count  = 1

 launch_type   = "FARGATE"



 network_configuration {

  subnets     = [aws_subnet.public.id]

  security_groups = [aws_security_group.frontend.id] # <- Accesible a través del SG de Frontend

  assign_public_ip = true

 }

}