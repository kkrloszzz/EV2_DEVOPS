# ============================================================
# outputs.tf — Valores de salida importantes
# ============================================================

output "vpc_id" {
  description = "ID de la VPC creada"
  value       = module.vpc.vpc_id
}

output "subnet_public_id" {
  description = "ID de la subred pública (Frontend)"
  value       = module.vpc.subnet_public_id
}

output "subnet_private_id" {
  description = "ID de la subred privada (Backend)"
  value       = module.vpc.subnet_private_id
}

output "ec2_frontend_public_ip" {
  description = "IP pública de la instancia EC2 Frontend — usar en el navegador"
  value       = module.ec2.frontend_public_ip
}

output "ec2_frontend_public_dns" {
  description = "DNS público de la instancia EC2 Frontend"
  value       = module.ec2.frontend_public_dns
}

output "ec2_backend_private_ip" {
  description = "IP privada de la instancia EC2 Backend — usar en VITE_API_URL"
  value       = module.ec2.backend_private_ip
}

output "ec2_frontend_id" {
  description = "ID de la instancia EC2 Frontend"
  value       = module.ec2.frontend_instance_id
}

output "ec2_backend_id" {
  description = "ID de la instancia EC2 Backend"
  value       = module.ec2.backend_instance_id
}

output "sg_frontend_id" {
  description = "ID del Security Group del Frontend"
  value       = module.security_groups.sg_frontend_id
}

output "sg_backend_id" {
  description = "ID del Security Group del Backend"
  value       = module.security_groups.sg_backend_id
}

output "ssh_frontend_command" {
  description = "Comando SSH para conectarse al Frontend"
  value       = "ssh -i ${var.key_name}.pem ec2-user@${module.ec2.frontend_public_ip}"
}

output "app_url" {
  description = "URL de acceso a la aplicación"
  value       = "http://${module.ec2.frontend_public_ip}"
}
