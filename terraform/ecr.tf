# ============================================================
# ecr.tf — Repositorios ECR (Elastic Container Registry)
# Almacena las imágenes Docker del proyecto Innovatech Chile
# ============================================================

resource "aws_ecr_repository" "repo_frontend" {
  name                 = "innovatech-frontend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  # Permite destruir el repo aunque tenga imágenes (útil en terraform destroy)
  force_delete = true

  tags = {
    Name    = "innovatech-frontend"
    Project = var.project_name
  }
}

resource "aws_ecr_repository" "repo_despachos" {
  name                 = "innovatech-backend-despachos"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = true

  tags = {
    Name    = "innovatech-backend-despachos"
    Project = var.project_name
  }
}

resource "aws_ecr_repository" "repo_ventas" {
  name                 = "innovatech-backend-ventas"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = true

  tags = {
    Name    = "innovatech-backend-ventas"
    Project = var.project_name
  }
}

# ──────────────────────────────────────────────
# Lifecycle policies — mantener solo las últimas 5 imágenes
# Evita acumular imágenes y agotar créditos de AWS Academy
# ──────────────────────────────────────────────
resource "aws_ecr_lifecycle_policy" "frontend" {
  repository = aws_ecr_repository.repo_frontend.name
  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Mantener solo las ultimas 5 imagenes"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 5
      }
      action = { type = "expire" }
    }]
  })
}

resource "aws_ecr_lifecycle_policy" "despachos" {
  repository = aws_ecr_repository.repo_despachos.name
  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Mantener solo las ultimas 5 imagenes"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 5
      }
      action = { type = "expire" }
    }]
  })
}

resource "aws_ecr_lifecycle_policy" "ventas" {
  repository = aws_ecr_repository.repo_ventas.name
  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Mantener solo las ultimas 5 imagenes"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 5
      }
      action = { type = "expire" }
    }]
  })
}
