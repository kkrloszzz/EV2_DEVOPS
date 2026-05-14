# ==========================================

# 1. ECS CLUSTER

# ==========================================

resource "aws_ecs_cluster" "innovatech_cluster" {

 name = "innovatech-cluster"

}



# ==========================================

# 2. ROL DE PERMISOS PARA DESCARGAR IMÁGENES

# ==========================================


data "aws_iam_role" "lab_role" {

 name = "LabRole"

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

 execution_role_arn =  data.aws_iam_role.lab_role.arn





 container_definitions = jsonencode([{

  name   = "ventas-container"

  image   = "730335299009.dkr.ecr.us-east-1.amazonaws.com/innovatech-backend-ventas:latest" # <-- REEMPLAZAR

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

 execution_role_arn    = data.aws_iam_role.lab_role.arn



 container_definitions = jsonencode([{

  name   = "despachos-container"

  image   = "730335299009.dkr.ecr.us-east-1.amazonaws.com/innovatech-backend-despachos:latest" # <-- REEMPLAZAR

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

 execution_role_arn    = data.aws_iam_role.lab_role.arn



 container_definitions = jsonencode([{

  name   = "frontend-container"

  image   = "730335299009.dkr.ecr.us-east-1.amazonaws.com/innovatech-frontend:latest" # <-- REEMPLAZAR

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