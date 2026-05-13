
output "frontend_instance_id" {
  description = "ID de la instancia EC2 Frontend"
  value       = aws_instance.frontend.id
}

output "frontend_public_ip" {
  description = "IP pública de la instancia EC2 Frontend"
  value       = aws_instance.frontend.public_ip
}

output "frontend_public_dns" {
  description = "DNS público de la instancia EC2 Frontend"
  value       = aws_instance.frontend.public_dns
}

output "backend_instance_id" {
  description = "ID de la instancia EC2 Backend"
  value       = aws_instance.backend.id
}

output "backend_private_ip" {
  description = "IP privada de la instancia EC2 Backend"
  value       = aws_instance.backend.private_ip
}
