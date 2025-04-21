variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs of public subnets"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "IDs of private subnets"
  type        = list(string)
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ec2_key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "ec2_instance_profile" {
  description = "IAM instance profile for EC2"
  type        = string
}

variable "todo_app_directory" {
  description = "Directory to store ToDo app files"
  type        = string
}

variable "app_repo_url" {
  description = "URL of the ToDo app GitHub repository"
  type        = string
}

# Email Configuration - no default values, passed from root
variable "email_host_user" {
  description = "Email address for sending notifications"
  type        = string
}

variable "email_host_password" {
  description = "Email password for sending notifications"
  type        = string
}

# African Taking API Configuration - no default values, passed from root
variable "african_taking_username" {
  description = "African Taking API username"
  type        = string
}

variable "african_taking_api_key" {
  description = "African Taking API key"
  type        = string
}

# Django Admin Configuration - no default values, passed from root
variable "django_admin_username" {
  description = "Django admin username"
  type        = string
}

variable "django_admin_email" {
  description = "Django admin email"
  type        = string
}

variable "django_admin_password" {
  description = "Django admin password"
  type        = string
}

# Django Secret Key - no default value, passed from root
variable "django_secret_key" {
  description = "Django secret key"
  type        = string
}

# Database Configuration - no default values, passed from root
variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
}