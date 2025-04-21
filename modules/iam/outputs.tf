locals {
  # Format the EC2 role ARN directly since we know it exists
  ec2_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project_name}-ec2-role"
  
  # Format the CloudWatch role ARN directly since we know it exists
  cloudwatch_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project_name}-cloudwatch-role"
}

output "ec2_role_arn" {
  description = "ARN of the EC2 role"
  value       = local.ec2_role_arn
}

output "ec2_instance_profile" {
  description = "EC2 instance profile name"
  value       = local.instance_profile_name
}

output "cloudwatch_role_arn" {
  description = "ARN of the CloudWatch logging role"
  value       = local.cloudwatch_role_arn
}