
# ──────────────────────────────────────────────
# VPC Principal
# ──────────────────────────────────────────────
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "${var.project_name}-vpc"
    Project = var.project_name
  }
}

# ──────────────────────────────────────────────
# Subred Pública — Frontend
# ──────────────────────────────────────────────
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_public_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true   # Las EC2 aquí reciben IP pública automáticamente

  tags = {
    Name    = "${var.project_name}-subnet-public"
    Project = var.project_name
    Tier    = "public"
  }
}

# ──────────────────────────────────────────────
# Subred Privada — Backend
# ──────────────────────────────────────────────
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_private_cidr
  availability_zone = var.availability_zone

  tags = {
    Name    = "${var.project_name}-subnet-private"
    Project = var.project_name
    Tier    = "private"
  }
}

# ──────────────────────────────────────────────
# Internet Gateway — salida a Internet para subred pública
# ──────────────────────────────────────────────
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project_name}-igw"
    Project = var.project_name
  }
}

# ──────────────────────────────────────────────
# Route Table Pública
# ──────────────────────────────────────────────
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # Ruta por defecto → Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name    = "${var.project_name}-rt-public"
    Project = var.project_name
  }
}

# Asociar Route Table pública a la subred pública
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ──────────────────────────────────────────────
# Route Table Privada
# ──────────────────────────────────────────────
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project_name}-rt-private"
    Project = var.project_name
  }
}

# Asociar Route Table privada a la subred privada
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
