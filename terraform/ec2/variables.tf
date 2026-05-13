# ============================================================
# modules/ec2/variables.tf
# ============================================================

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
}

variable "key_name" {
  description = "Nombre del par de claves SSH"
  type        = string
}

variable "ami_id" {
  description = "ID de la AMI (Amazon Linux 2023)"
  type        = string
}

variable "subnet_public_id" {
  description = "ID de la subred pública (para el Frontend)"
  type        = string
}

variable "subnet_private_id" {
  description = "ID de la subred privada (para el Backend)"
  type        = string
}

variable "sg_frontend_id" {
  description = "ID del Security Group del Frontend"
  type        = string
}

variable "sg_backend_id" {
  description = "ID del Security Group del Backend"
  type        = string
}
