# ============================================================
# modules/vpc/variables.tf
# ============================================================

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block de la VPC"
  type        = string
}

variable "subnet_public_cidr" {
  description = "CIDR de la subred pública"
  type        = string
}

variable "subnet_private_cidr" {
  description = "CIDR de la subred privada"
  type        = string
}

variable "availability_zone" {
  description = "Zona de disponibilidad"
  type        = string
}
