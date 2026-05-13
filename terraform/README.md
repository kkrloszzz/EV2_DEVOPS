# 🏗️ Infraestructura AWS — Innovatech Chile (EP1)
## ISY1101 — Introducción a Herramientas DevOps

Infraestructura como código (IaC) con Terraform para desplegar la arquitectura base en AWS que soporta la aplicación de Innovatech Chile.

---

## 📁 Estructura del proyecto

```
terraform/
├── main.tf                         # Orquestador principal (llama a módulos)
├── variables.tf                    # Definición de variables
├── outputs.tf                      # Valores de salida
├── terraform.tfvars                # Valores de las variables (COMPLETAR)
└── modules/
    ├── vpc/
    │   ├── main.tf                 # VPC, subnets, IGW, route tables
    │   ├── variables.tf
    │   └── outputs.tf
    ├── security_groups/
    │   ├── main.tf                 # SG Frontend y Backend
    │   ├── variables.tf
    │   └── outputs.tf
    └── ec2/
        ├── main.tf                 # Instancias EC2 (Frontend + Backend)
        ├── variables.tf
        └── outputs.tf
```

---

## 🏛️ Arquitectura desplegada

```
Internet
    │
    ▼
[Internet Gateway]
    │
    ▼
┌─────────────────────────────────────────┐
│           VPC: 10.0.0.0/16              │
│                                         │
│  ┌──────────────────────────────────┐   │
│  │  Subred Pública: 10.0.1.0/24    │   │
│  │                                  │   │
│  │  EC2 Frontend (t2.micro)         │   │
│  │  SG: 80, 443 público / 22 mi IP  │   │
│  │  contenedor: front-despacho:80   │   │
│  └────────────┬─────────────────────┘   │
│               │ puerto 8081             │
│  ┌────────────▼─────────────────────┐   │
│  │  Subred Privada: 10.0.2.0/24    │   │
│  │                                  │   │
│  │  EC2 Backend (t2.micro)          │   │
│  │  SG: 8080/8081 desde Frontend    │   │
│  │  contenedor: back-despacho:8081  │   │
│  │  contenedor: back-ventas:8080    │   │
│  │  contenedor: MySQL:3306          │   │
│  └──────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

**Solo el Frontend es accesible desde Internet.**
El Backend solo acepta tráfico desde el Security Group del Frontend.

---

## ⚙️ Recursos creados

| Recurso | Nombre | Descripción |
|---|---|---|
| VPC | innovatech-vpc | Red principal 10.0.0.0/16 |
| Subnet | innovatech-subnet-public | Subred pública para Frontend |
| Subnet | innovatech-subnet-private | Subred privada para Backend |
| Internet Gateway | innovatech-igw | Salida a Internet |
| Route Table | innovatech-rt-public | Rutas de la subred pública |
| Route Table | innovatech-rt-private | Rutas de la subred privada |
| Security Group | innovatech-sg-frontend | Reglas para EC2 Frontend |
| Security Group | innovatech-sg-backend | Reglas para EC2 Backend |
| EC2 | innovatech-ec2-frontend | Instancia Frontend (t2.micro) |
| EC2 | innovatech-ec2-backend | Instancia Backend (t2.micro) |

---

## 🚀 Cómo usar

### 1. Prerrequisitos
```bash
# Instalar Terraform
# https://developer.hashicorp.com/terraform/downloads

# Verificar instalación
terraform --version

# Configurar credenciales AWS Academy
aws configure
# AWS Access Key ID: (de AWS Academy → AWS Details)
# AWS Secret Access Key: (de AWS Academy → AWS Details)
# Default region: us-east-1
# Default output format: json
```

### 2. Crear par de claves en AWS
```
AWS Console → EC2 → Key Pairs → Create key pair
- Name: mi-clave-innovatech
- Type: RSA
- Format: .pem
- Descargar y guardar en lugar seguro
```

### 3. Completar terraform.tfvars
```hcl
key_name = "mi-clave-innovatech"   # Nombre de tu clave (sin .pem)
my_ip    = "x.x.x.x/32"           # Tu IP: ejecutar curl ifconfig.me
```

### 4. Inicializar Terraform
```bash
cd terraform/
terraform init
```

### 5. Ver plan de ejecución
```bash
terraform plan
```

### 6. Aplicar infraestructura
```bash
terraform apply
# Escribir "yes" para confirmar
```

### 7. Ver outputs (IPs de las instancias)
```bash
terraform output
```

Ejemplo de salida:
```
app_url                  = "http://54.123.45.67"
ec2_backend_private_ip   = "10.0.2.45"
ec2_frontend_public_ip   = "54.123.45.67"
ssh_frontend_command     = "ssh -i mi-clave-innovatech.pem ec2-user@54.123.45.67"
```

### 8. Destruir infraestructura (cuando no se use)
```bash
terraform destroy
# Escribir "yes" para confirmar
# ⚠️ AWS Academy tiene límite de créditos — destruir cuando no se use
```

---

## 🔐 Credenciales AWS Academy

Cada vez que se inicia el laboratorio en AWS Academy, las credenciales cambian. Actualizar con:

```bash
aws configure
# O editar directamente:
nano ~/.aws/credentials
```

---

## 📝 Notas importantes

- **AWS Academy** resetea las credenciales al terminar la sesión del laboratorio. Volver a configurar con `aws configure` cada vez.
- Las instancias EC2 se crean con Docker y Docker Compose pre-instalados gracias al `user_data`.
- El Backend **no tiene IP pública** por diseño de seguridad — solo es accesible desde el Frontend dentro de la VPC.
- Para SSH al Backend, usar el Frontend como bastión o configurar AWS Systems Manager.
