
variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC donde se crean los Security Groups"
  type        = string
}

variable "my_ip" {
  description = "Tu IP pública para permitir SSH (formato: x.x.x.x/32)"
  type        = string
}
