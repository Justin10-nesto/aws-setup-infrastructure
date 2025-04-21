variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "eu-north-1"
}

# Credentials and Sensitive Information
variable "aws_access_key" {
  description = "AWS access key"
  type        = string
  sensitive   = true
  # SECURITY FIX: Removed hardcoded credentials
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
  sensitive   = true
  # SECURITY FIX: Removed hardcoded credentials
}

# Email Configuration
variable "email_host_user" {
  description = "Email address for sending notifications"
  type        = string
  sensitive   = true
  # SECURITY FIX: Removed hardcoded email
}

variable "email_host_password" {
  description = "Email password for sending notifications"
  type        = string
  sensitive   = true
  # SECURITY FIX: Removed hardcoded password
}

# African Taking API Configuration
variable "african_taking_username" {
  description = "African Taking API username"
  type        = string
  sensitive   = true
  # SECURITY FIX: Removed hardcoded API username
}

variable "african_taking_api_key" {
  description = "African Taking API key"
  type        = string
  sensitive   = true
  # SECURITY FIX: Removed hardcoded API key
}

# Django Admin Configuration
variable "django_admin_username" {
  description = "Django admin username"
  type        = string
  default     = "admin"
}

variable "django_admin_email" {
  description = "Django admin email"
  type        = string
  default     = "admin@example.com"
}

variable "django_admin_password" {
  description = "Django admin password"
  type        = string
  sensitive   = true
  # SECURITY FIX: Removed hardcoded password
}

# Django Secret Key
variable "django_secret_key" {
  description = "Django secret key"
  type        = string
  sensitive   = true
  # SECURITY FIX: Removed hardcoded secret key
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "todo-app"
}

# Key Pair Configuration
variable "key_name" {
  description = "Name of the EC2 key pair"
  type        = string
  default     = "todo-app-key"
}

variable "public_key_path" {
  description = "Path to the public key for EC2 instances"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["eu-north-1a", "eu-north-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

# NAT Instance Configuration
variable "nat_instance_type" {
  description = "Instance type for NAT instance"
  type        = string
  default     = "t3.micro"
}

variable "nat_instance_key_name" {
  description = "Key pair name for NAT instance"
  type        = string
  default     = "todo-app-key"
}

variable "ssh_allowed_cidrs" {
  description = "CIDR blocks allowed to SSH to NAT instance"
  type        = list(string)
  default     = ["0.0.0.0/0"] # For production, restrict to specific IPs
}

# EC2 Configuration
variable "ec2_instance_type" {
  description = "Instance type for EC2"
  type        = string
  default     = "t3.micro"  # Changed back to t3.micro as t2.micro isn't supported in eu-north-1
}

variable "ec2_key_name" {
  description = "Key pair name for EC2 instance"
  type        = string
  default     = "todo-app-key"
}

variable "todo_app_directory" {
  description = "Directory path for ToDo app source code"
  type        = string
  default     = "../ToDo-APP"
}

# Database Configuration
variable "use_rds_instead_of_docker" {
  description = "Whether to use RDS instead of Docker MySQL"
  type        = bool
  default     = false
}

variable "db_instance_class" {
  description = "Database instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "todo_db"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "todo_admin"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
  # SECURITY FIX: Removed hardcoded password
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 3306
}