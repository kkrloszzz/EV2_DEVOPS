
output "sg_frontend_id" {
  description = "ID del Security Group del Frontend"
  value       = aws_security_group.frontend.id
}

output "sg_backend_id" {
  description = "ID del Security Group del Backend"
  value       = aws_security_group.backend.id
}
