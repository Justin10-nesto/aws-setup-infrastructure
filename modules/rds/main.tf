resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

resource "aws_security_group" "rds_sg" {
  count = var.create_rds_instance ? 1 : 0
  
  name        = "${var.project_name}-rds-sg"
  description = "Security group for RDS instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

# Parameter group to enable automatic initialization scripts
resource "aws_db_parameter_group" "todo_db" {
  count = var.create_rds_instance ? 1 : 0
  
  name        = "${var.project_name}-db-params"
  family      = "mysql8.0"
  description = "Parameter group for ${var.project_name} RDS instance"

  # Enable automatic initialization
  parameter {
    name  = "local_infile"
    value = "1"
  }

  tags = {
    Name = "${var.project_name}-db-params"
  }
}

resource "aws_db_instance" "main" {
  allocated_storage      = var.db_allocated_storage
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "14"
  instance_class         = var.db_instance_class
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.postgres14"
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.db_security_group_id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  
  tags = {
    Name = "${var.project_name}-db"
  }
}