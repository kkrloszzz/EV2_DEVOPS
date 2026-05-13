# ============================================================
# modules/ec2/main.tf
# Instancias EC2: Frontend (pública) + Backend (privada)
# ============================================================

# ──────────────────────────────────────────────
# User Data — Script de instalación de Docker
# Se ejecuta automáticamente al iniciar la instancia
# ──────────────────────────────────────────────
locals {
  user_data_docker = <<-EOF
    #!/bin/bash
    # Actualizar paquetes
    dnf update -y

    # Instalar Docker
    dnf install -y docker git

    # Iniciar y habilitar Docker
    systemctl start docker
    systemctl enable docker

    # Agregar ec2-user al grupo docker
    usermod -aG docker ec2-user

    # Instalar Docker Compose
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
      -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    echo "Docker y Docker Compose instalados correctamente" >> /var/log/user-data.log
  EOF
}

# ──────────────────────────────────────────────
# EC2 Frontend — Subred Pública
# Sirve la aplicación React en el puerto 80
# ──────────────────────────────────────────────
resource "aws_instance" "frontend" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_public_id
  vpc_security_group_ids      = [var.sg_frontend_id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  # Instalar Docker automáticamente al iniciar
  user_data = local.user_data_docker

  # Volumen raíz — 20GB suficiente para Docker images
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true

    tags = {
      Name    = "${var.project_name}-vol-frontend"
      Project = var.project_name
    }
  }

  tags = {
    Name    = "${var.project_name}-ec2-frontend"
    Project = var.project_name
    Tier    = "public"
    Role    = "frontend"
  }
}

# ──────────────────────────────────────────────
# EC2 Backend — Subred Privada
# Sirve la API Spring Boot (8080/8081) + MySQL
# ──────────────────────────────────────────────
resource "aws_instance" "backend" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_private_id
  vpc_security_group_ids      = [var.sg_backend_id]
  key_name                    = var.key_name
  associate_public_ip_address = false   # Sin IP pública — subred privada

  # Instalar Docker automáticamente al iniciar
  user_data = local.user_data_docker

  # Volumen raíz — 30GB para Docker + MySQL data
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = true

    tags = {
      Name    = "${var.project_name}-vol-backend"
      Project = var.project_name
    }
  }

  tags = {
    Name    = "${var.project_name}-ec2-backend"
    Project = var.project_name
    Tier    = "private"
    Role    = "backend"
  }
}
