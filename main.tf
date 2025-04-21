terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Use the correct data source for key pair check
locals {
  key_name = "todo-app-key"
  # Default placeholder endpoint when EC2 instance is not created
  default_endpoint = "127.0.0.1:8000"
}

# VPC and Network Configuration
module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  
  # NAT Instance configuration
  nat_instance_type     = var.nat_instance_type
  nat_instance_key_name = local.key_name
  ssh_allowed_cidrs     = var.ssh_allowed_cidrs
  db_port               = var.db_port
}

# IAM Roles and Policies for EC2
module "iam" {
  source = "./modules/iam"
  
  project_name = var.project_name
}

# EC2 Instance for Docker deployment
module "ec2" {
  source = "./modules/ec2"
  
  project_name         = var.project_name
  vpc_id               = module.vpc.vpc_id
  public_subnet_ids    = module.vpc.public_subnet_ids
  private_subnet_ids   = module.vpc.private_subnet_ids
  ec2_instance_type    = var.ec2_instance_type
  ec2_key_name         = local.key_name
  todo_app_directory   = var.todo_app_directory
  ec2_instance_profile = module.iam.ec2_instance_profile
  app_repo_url         = "https://github.com/Justin10-nesto/ToDo-APP.git"
  
  # Pass credential variables from root variables
  email_host_user       = var.email_host_user
  email_host_password   = var.email_host_password
  african_taking_username = var.african_taking_username
  african_taking_api_key  = var.african_taking_api_key
  django_admin_username = var.django_admin_username
  django_admin_email    = var.django_admin_email
  django_admin_password = var.django_admin_password
  django_secret_key     = var.django_secret_key
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
}

# API Gateway for REST API
module "api_gateway" {
  source = "./modules/api_gateway"
  
  project_name       = var.project_name
  ec2_endpoint       = module.ec2.ec2_public_ip != null ? "${module.ec2.ec2_public_ip}:8000" : local.default_endpoint
  api_stage_name     = "v1"
  cloudwatch_role_arn = module.iam.cloudwatch_role_arn
}