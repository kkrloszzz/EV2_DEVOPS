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

# COMPLETAR: nombre del par de claves creado en AWS Console (sin .pem)
key_name = "claves-innovatech"

# COMPLETAR: tu IP pública real (ejecutar en tu PC: curl ifconfig.me)
# ⚠️  192.168.1.120 es tu IP LOCAL — no sirve para SSH desde Internet
# Reemplazar con tu IP pública real en formato x.x.x.x/32
my_ip = "0.0.0.0/0"
