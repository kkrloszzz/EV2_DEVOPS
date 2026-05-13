
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ============================================================
# MÓDULO: VPC + Subnets + Internet Gateway + Route Tables
# ============================================================
module "vpc" {
  source = "./vpc"

  project_name        = var.project_name
  vpc_cidr            = var.vpc_cidr
  subnet_public_cidr  = var.subnet_public_cidr
  subnet_private_cidr = var.subnet_private_cidr
  availability_zone   = var.availability_zone
}

# ============================================================
# MÓDULO: Security Groups
# ============================================================
module "security_groups" {
  source = "./security_groups"

  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
  my_ip        = var.my_ip
}

# ============================================================
# MÓDULO: Instancias EC2
# ============================================================
module "ec2" {
  source = "./ec2"

  project_name          = var.project_name
  instance_type         = var.instance_type
  key_name              = var.key_name
  ami_id                = var.ami_id

  # Frontend → subred pública
  subnet_public_id      = module.vpc.subnet_public_id
  sg_frontend_id        = module.security_groups.sg_frontend_id

  # Backend → subred privada
  subnet_private_id     = module.vpc.subnet_private_id
  sg_backend_id         = module.security_groups.sg_backend_id
}
