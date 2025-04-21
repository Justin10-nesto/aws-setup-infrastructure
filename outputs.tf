output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = module.api_gateway.api_endpoint
}

output "api_invoke_url" {
  description = "API Gateway invoke URL"
  value       = module.api_gateway.api_url
}

output "db_connection_info" {
  description = "Database connection information"
  value = {
    # Since we're using Docker-based PostgreSQL, the host is always the EC2 instance
    host     = module.ec2.ec2_public_ip
    port     = var.db_port
    name     = var.db_name
    username = var.db_username
  }
  sensitive = true
}

output "ec2_instance_public_ip" {
  description = "Public IP of the EC2 instance running the ToDo application"
  value       = module.ec2.ec2_public_ip
}

output "ec2_instance_dns" {
  description = "Public DNS of the EC2 instance"
  value       = module.ec2.ec2_public_dns
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "deployment_instructions" {
  description = "Instructions for accessing the deployed application"
  value       = <<-EOT
    Access the ToDo application through:
    1. IP Address: http://${module.ec2.ec2_public_ip} or https://${module.ec2.ec2_public_ip} 
    2. DNS Name: http://${module.ec2.ec2_public_dns} or https://${module.ec2.ec2_public_dns}
    3. Domain (if configured): https://todo.tradesync.software
    
    Note: It may take a few minutes for the application to be fully deployed.
    The Elastic IP address ${module.ec2.ec2_public_ip} will remain stable even if the instance is stopped and restarted.
  EOT
}