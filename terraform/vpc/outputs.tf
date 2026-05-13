
output "vpc_id" {
  description = "ID de la VPC"
  value       = aws_vpc.main.id
}

output "subnet_public_id" {
  description = "ID de la subred pública"
  value       = aws_subnet.public.id
}

output "subnet_private_id" {
  description = "ID de la subred privada"
  value       = aws_subnet.private.id
}

output "internet_gateway_id" {
  description = "ID del Internet Gateway"
  value       = aws_internet_gateway.main.id
}
