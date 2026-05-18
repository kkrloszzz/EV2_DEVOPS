# ============================================================
# ec2.tf — Instancias EC2
# Frontend (subred pública) + Backend (subred privada)
# Docker, Docker Compose y AWS CLI instalados via user_data
# ============================================================

locals {
  user_data_docker = <<-EOF
    #!/bin/bash
    # Actualizar paquetes
    dnf update -y

    # Instalar Docker, Git y AWS CLI
    dnf install -y docker git aws-cli

    # Iniciar y habilitar Docker
    systemctl start docker
    systemctl enable docker

    # Agregar ec2-user al grupo docker (sin necesidad de sudo)
    usermod -aG docker ec2-user

    # Instalar Docker Compose v2
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
      -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    echo "✅ Docker, Docker Compose y AWS CLI instalados" >> /var/log/user-data.log
  EOF
}

# ──────────────────────────────────────────────
# EC2 Frontend — Subred Pública
# ──────────────────────────────────────────────
resource "aws_instance" "frontend" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.frontend.id]
  key_name                    = var.key_name
  associate_public_ip_address = true
  user_data                   = local.user_data_docker

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
# ──────────────────────────────────────────────
resource "aws_instance" "backend" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.private.id
  vpc_security_group_ids      = [aws_security_group.backend.id]
  key_name                    = var.key_name
  associate_public_ip_address = false
  user_data                   = local.user_data_docker

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
