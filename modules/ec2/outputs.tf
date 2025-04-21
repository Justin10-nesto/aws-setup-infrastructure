output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = length(aws_instance.todo_app) > 0 ? aws_instance.todo_app[0].id : null
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = length(aws_eip.ec2_eip) > 0 ? aws_eip.ec2_eip[0].public_ip : (length(aws_instance.todo_app) > 0 ? aws_instance.todo_app[0].public_ip : null)
}

output "ec2_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = length(aws_instance.todo_app) > 0 ? aws_instance.todo_app[0].private_ip : null
}

output "ec2_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = length(aws_instance.todo_app) > 0 ? aws_instance.todo_app[0].public_dns : null
}

output "ec2_security_group_id" {
  description = "ID of the EC2 security group"
  value       = local.sg_id
}