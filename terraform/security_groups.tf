
# ──────────────────────────────────────────────
# Security Group — EC2 Frontend (subred pública)
# ──────────────────────────────────────────────
resource "aws_security_group" "frontend" {
  name        = "${var.project_name}-sg-frontend"
  description = "Security Group para instancia EC2 Frontend"
  vpc_id      = aws_vpc.main.id

  # HTTP desde Internet (acceso público a la app)
  ingress {
    description = "HTTP desde Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS desde Internet (por si se agrega SSL)
  ingress {
    description = "HTTPS desde Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH solo desde tu IP (acceso administrativo)
  ingress {
    description = "SSH desde mi IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # Todo el tráfico saliente permitido
  egress {
    description = "Todo el trafico saliente"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-sg-frontend"
    Project = var.project_name
    Tier    = "public"
  }
}

# ──────────────────────────────────────────────
# Security Group — EC2 Backend (subred privada)
# ──────────────────────────────────────────────
resource "aws_security_group" "backend" {
  name        = "${var.project_name}-sg-backend"
  description = "Security Group para instancia EC2 Backend"
  vpc_id      = aws_vpc.main.id

  # Puerto 8081 (API Despachos) — solo desde el SG Frontend
  ingress {
    description     = "API Despachos desde Frontend"
    from_port       = 8081
    to_port         = 8081
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend.id]
  }

  # Puerto 8080 (API Ventas) — solo desde el SG Frontend
  ingress {
    description     = "API Ventas desde Frontend"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend.id]
  }

  # SSH solo desde tu IP (acceso administrativo)
  ingress {
    description = "SSH desde mi IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # Todo el tráfico saliente permitido (para que el backend pueda descargar imágenes Docker)
  egress {
    description = "Todo el trafico saliente"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-sg-backend"
    Project = var.project_name
    Tier    = "private"
  }
}
