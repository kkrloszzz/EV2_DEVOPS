



# 1. Repositorio para el Backend de Ventas

resource "aws_ecr_repository" "repo_ventas" {
 name         = "innovatech-backend-ventas"
 image_tag_mutability = "MUTABLE"
 image_scanning_configuration {
  scan_on_push = true
 }

}



# 2. Repositorio para el Backend de Despachos

resource "aws_ecr_repository" "repo_despachos" {

 name         = "innovatech-backend-despachos"

 image_tag_mutability = "MUTABLE"



 image_scanning_configuration {

  scan_on_push = true

 }

}



# 3. Repositorio para el Frontend

resource "aws_ecr_repository" "repo_frontend" {

 name         = "innovatech-frontend"

 image_tag_mutability = "MUTABLE"



 image_scanning_configuration {

  scan_on_push = true

 }

}