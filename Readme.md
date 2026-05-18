# Innovatech — Plataforma Logística de Microservicios

**Descripción** 
Infraestructura y código gestionado para desplegar:

- Dos microservicios Backend (Ventas y Despachos) en Spring Boot.
- Un Frontend servido a través de Nginx.
- Redes de AWS (VPC, Subred pública, Internet Gateway).
- Reglas de firewall mediante Security Groups.
- Repositorios elásticos de contenedores (AWS ECR).
- Orquestación de contenedores serverless (AWS ECS Fargate).
- Entorno de desarrollo local unificado con Docker Compose.

---

## 🧭 Estructura del proyecto

```
EV2_DEVOPS/
├── back-Despachos_SpringBoot/
├── back-Ventas_SpringBoot/
├── front_despacho/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── vpc.tf
│   ├── security_groups.tf
│   ├── ec2.tf
│   ├── ecr.tf
│   └── ecs.tf
├── .env
├── docker-compose.yml
└── README.md
```

## 🚀 Requisitos

- Terraform CLI versión >= 1.0
- Docker Desktop ejecutándose en entorno local
- AWS CLI configurado con credenciales activas (Soporte para Vocareum / AWS Academy)
- Suscripción AWS con permisos para ECS, ECR, EC2 y VPC

---

## ⚙️ Flujo de uso

1. Levanta el entorno de desarrollo local (opcional):

```
docker-compose up -d --build
```

2. Inicializa Terraform:

```
cd terraform
terraform init
```

Verifica el plan de infraestructura:

```
terraform plan
```

Aplica los cambios en AWS:

```
terraform apply
```

3. Sube las imágenes Docker a AWS ECR:

```
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin TU_ID_CUENTA.dkr.ecr.us-east-1.amazonaws.com

docker tag innovatech-backend-ventas:latest TU_ID_[CUENTA.dkr.ecr.us-east-1.amazonaws.com/innovatech-backend-ventas:latest](https://CUENTA.dkr.ecr.us-east-1.amazonaws.com/innovatech-backend-ventas:latest)
docker push TU_ID_[CUENTA.dkr.ecr.us-east-1.amazonaws.com/innovatech-backend-ventas:latest](https://CUENTA.dkr.ecr.us-east-1.amazonaws.com/innovatech-backend-ventas:latest)

docker tag innovatech-backend-despachos:latest TU_ID_[CUENTA.dkr.ecr.us-east-1.amazonaws.com/innovatech-backend-despachos:latest](https://CUENTA.dkr.ecr.us-east-1.amazonaws.com/innovatech-backend-despachos:latest)
docker push TU_ID_[CUENTA.dkr.ecr.us-east-1.amazonaws.com/innovatech-backend-despachos:latest](https://CUENTA.dkr.ecr.us-east-1.amazonaws.com/innovatech-backend-despachos:latest)

docker tag innovatech-frontend:latest TU_ID_[CUENTA.dkr.ecr.us-east-1.amazonaws.com/innovatech-frontend:latest](https://CUENTA.dkr.ecr.us-east-1.amazonaws.com/innovatech-frontend:latest)
docker push TU_ID_[CUENTA.dkr.ecr.us-east-1.amazonaws.com/innovatech-frontend:latest](https://CUENTA.dkr.ecr.us-east-1.amazonaws.com/innovatech-frontend:latest)
```

## 📦 ¿Qué despliega este proyecto?

Componentes de software: APIs REST para Ventas (puerto 8080) y Despachos (puerto 8081) desarrolladas en Spring Boot, orquestadas junto a una interfaz Frontend (puerto 80) para el consumo de los servicios.

Infraestructura cloud: Crea una VPC con salida a internet, Security Groups estrictos, repositorios ECR para almacenar las imágenes Docker, y un clúster ECS Fargate que ejecuta las tareas sin necesidad de administrar la capa de servidores físicos.

Se gestiona el flujo garantizando que ECS auto-despliegue los contenedores tras realizar el `push` de las imágenes a ECR.

Soporte integrado para despliegues en laboratorios educativos usando el rol preexistente `LabRole`.



## 📌 Mejores prácticas incluidas

Seguridad de red estricta mediante Security Groups, donde las APIs Backend bloquean todo el tráfico de internet y solo reciben peticiones originadas desde el SG del Frontend.

Estructura de Infraestructura inmutable totalmente gestionada como código (IaC).

Arquitectura plana en Terraform para facilitar la lectura de dependencias e IDs compartidos entre recursos.

Uso del principio de mínimo privilegio adaptado a restricciones de entornos educativos de AWS.

## 🔧 Cómo extender este proyecto

Agregar un Application Load Balancer (ALB) para distribuir el tráfico web de forma escalable.

Desplegar una base de datos relacional administrada, como AWS RDS (MySQL/PostgreSQL).

Automatizar el flujo completo de construcción y despliegue usando CI/CD con GitHub Actions o AWS CodePipeline.

Asignar nombres de dominio personalizados mediante AWS Route 53 e integrar certificados HTTPS con AWS ACM.
