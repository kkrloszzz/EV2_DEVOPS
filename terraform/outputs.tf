# ============================================================
# outputs.tf — Valores de salida importantes
# ============================================================

output "vpc_id" {
  description = "ID de la VPC creada"
  value       = aws_vpc.main.id
}

output "subnet_public_id" {
  description = "ID de la subred pública (Frontend)"
  value       = aws_subnet.public.id
}

output "subnet_private_id" {
  description = "ID de la subred privada (Backend)"
  value       = aws_subnet.private.id
}

output "internet_gateway_id" {
  description = "ID del Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "sg_frontend_id" {
  description = "ID del Security Group del Frontend"
  value       = aws_security_group.frontend.id
}

output "sg_backend_id" {
  description = "ID del Security Group del Backend"
  value       = aws_security_group.backend.id
}

output "ec2_frontend_id" {
  description = "ID de la instancia EC2 Frontend"
  value       = aws_instance.frontend.id
}

output "ec2_frontend_public_ip" {
  description = "IP pública de la instancia EC2 Frontend — usar en el navegador"
  value       = aws_instance.frontend.public_ip
}

output "ec2_frontend_public_dns" {
  description = "DNS público de la instancia EC2 Frontend"
  value       = aws_instance.frontend.public_dns
}

output "ec2_backend_id" {
  description = "ID de la instancia EC2 Backend"
  value       = aws_instance.backend.id
}

output "ec2_backend_private_ip" {
  description = "IP privada de la instancia EC2 Backend — usar en VITE_API_URL"
  value       = aws_instance.backend.private_ip
}

output "ssh_frontend_command" {
  description = "Comando SSH para conectarse al Frontend"
  value       = "ssh -i ${var.key_name}.pem ec2-user@${aws_instance.frontend.public_ip}"
}

output "app_url" {
  description = "URL de acceso a la aplicación"
  value       = "http://${aws_instance.frontend.public_ip}"
}
