data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Check if security group already exists
data "aws_security_groups" "existing_sg" {
  filter {
    name   = "group-name"
    values = ["${var.project_name}-ec2-sg"]
  }
  
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

# Get the specific security group if it exists
data "aws_security_group" "existing_sg_details" {
  count = length(data.aws_security_groups.existing_sg.ids) > 0 ? 1 : 0
  id    = data.aws_security_groups.existing_sg.ids[0]
}

# Security group for EC2 instance
resource "aws_security_group" "ec2_sg" {
  # Skip creation if security group already exists
  count       = local.sg_exists ? 0 : 1
  
  name        = "${var.project_name}-ec2-sg"
  description = "Security group for EC2 instance running ToDo app"
  vpc_id      = var.vpc_id

  # Allow SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Consider restricting to your IP for better security
  }

  # Allow HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow application port
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Check if an instance with the same name tag already exists
data "aws_instances" "existing_todo_app" {
  filter {
    name   = "tag:Name"
    values = ["${var.project_name}-ec2-instance"]
  }
  
  filter {
    name   = "instance-state-name"
    values = ["running", "stopped", "pending"]
  }
  
  # This prevents failure if no instances are found
  instance_state_names = ["running", "stopped", "pending"]
}

locals {
  # Check if we found any instances
  instance_exists = length(data.aws_instances.existing_todo_app.ids) > 0
  
  # Check if security group exists
  sg_exists = length(data.aws_security_groups.existing_sg.ids) > 0
  
  # Get the ID of the existing security group if it exists
  sg_id = local.sg_exists ? data.aws_security_group.existing_sg_details[0].id : (length(aws_security_group.ec2_sg) > 0 ? aws_security_group.ec2_sg[0].id : "")
}

# EC2 instance for running the ToDo app with Docker
resource "aws_instance" "todo_app" {
  # Skip creation if instance already exists
  count                = local.instance_exists ? 0 : 1
  
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.ec2_instance_type
  subnet_id              = var.public_subnet_ids[0]
  vpc_security_group_ids = [local.sg_id]
  key_name               = var.ec2_key_name
  iam_instance_profile   = var.ec2_instance_profile
  associate_public_ip_address = true

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }

  user_data = <<-EOF
    #!/bin/bash
    
    # Update system
    yum update -y
    
    # Install Docker and Git
    amazon-linux-extras install docker -y
    yum install -y git
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ec2-user
    
    # Install Docker Compose
    curl -L "https://github.com/docker/compose/releases/download/v2.18.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    
    # Create app directory
    mkdir -p ${var.todo_app_directory}
    cd ${var.todo_app_directory}
    
    # Clone the repository (includes docker-compose.yml and entrypoint.sh)
    git clone ${var.app_repo_url} .
    
    # Create Docker networks
    docker network create public_net || true
    docker network create --internal private_net || true
    
    # Create .env file with variables from Terraform
    cat > .env << EOL
    ENGINE=django.db.backends.postgresql_psycopg2
    EMAIL_HOST_USER=${var.email_host_user}
    EMAIL_HOST_PASSWORD=${var.email_host_password}
    DATABASE_PASSWORD=${var.db_password}
    DATABASE_USER=${var.db_username}
    NAME=${var.db_name}
    PORT=5432
    HOST=database
    AfricanTakingUsername=${var.african_taking_username}
    AfricanTakingApi=${var.african_taking_api_key}
    
    POSTGRES_PASSWORD=${var.db_password}
    POSTGRES_USER=${var.db_username}
    POSTGRES_DB=${var.db_name}
    POSTGRES_HOST=database
    
    DJANGO_SECRET_KEY=${var.django_secret_key}
    DJANGO_ADMIN_USERNAME=${var.django_admin_username}
    DJANGO_ADMIN_EMAIL=${var.django_admin_email}
    DJANGO_ADMIN_PASSWORD=${var.django_admin_password}
    
    PORT=8000
    EOL

    # Setup Traefik permissions
    touch acme.json
    chmod 600 acme.json
    
    # Start services using the existing docker-compose.yml
    docker-compose up -d
  EOF

  tags = {
    Name = "${var.project_name}-ec2-instance"
  }
}

# Elastic IP for EC2 instance - only create if instance is created
resource "aws_eip" "ec2_eip" {
  count     = local.instance_exists ? 0 : 1
  instance  = local.instance_exists ? null : aws_instance.todo_app[0].id
  domain    = "vpc"

  tags = {
    Name = "${var.project_name}-ec2-eip"
  }
}

# If we found an existing instance, get its IP/DNS
data "aws_instance" "existing_instance" {
  count       = local.instance_exists ? 1 : 0
  filter {
    name   = "tag:Name"
    values = ["${var.project_name}-ec2-instance"]
  }
}