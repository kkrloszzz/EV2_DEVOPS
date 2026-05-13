# ============================================================
# terraform.tfvars — Valores de las variables
# IMPORTANTE: Completar key_name y my_ip antes de aplicar
# No subir este archivo a GitHub si contiene datos sensibles
# ============================================================

aws_region   = "us-east-1"
project_name = "innovatech"

# Red
vpc_cidr            = "10.0.0.0/16"
subnet_public_cidr  = "10.0.1.0/24"
subnet_private_cidr = "10.0.2.0/24"
availability_zone   = "us-east-1a"

# EC2
instance_type = "t2.micro"
ami_id        = "ami-0c02fb55956c7d316"  # Amazon Linux 2023 - us-east-1

# COMPLETAR: nombre del par de claves creado en AWS (sin .pem)
key_name = "mi-clave-innovatech"

# COMPLETAR: tu IP pública (ejecutar: curl ifconfig.me)
my_ip = "0.0.0.0/0"  # Cambiar por tu IP real: "x.x.x.x/32"
