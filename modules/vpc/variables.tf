variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 3306
}

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