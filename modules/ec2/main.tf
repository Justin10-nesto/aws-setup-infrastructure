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

# Create security group directly without checking if it exists first
resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-ec2-sg"
  description = "Security group for EC2 instance running ToDo app"
  vpc_id      = var.vpc_id

  # Allow SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

# Use local values to simplify references to resources
locals {
  sg_id = aws_security_group.ec2_sg.id
  
  create_new_instance = true 
  instance_type = "t3.micro"  # Changed back to t3.micro as t2.micro isn't supported in eu-north-1
}

resource "aws_instance" "todo_app" {
  count = local.create_new_instance ? 1 : 0
  
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = local.instance_type
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
    amazon-linux-extras install -y docker
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

# Elastic IP for EC2 instance
resource "aws_eip" "ec2_eip" {
  count     = local.create_new_instance ? 1 : 0
  instance  = length(aws_instance.todo_app) > 0 ? aws_instance.todo_app[0].id : null
  domain    = "vpc"

  tags = {
    Name = "${var.project_name}-ec2-eip"
  }
  
  # Only create if we are creating an instance
  depends_on = [aws_instance.todo_app]
}