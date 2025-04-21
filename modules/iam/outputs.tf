output "ec2_role_arn" {
  description = "ARN of the EC2 role"
  value       = aws_iam_role.ec2_role.arn
}

output "ec2_instance_profile" {
  description = "EC2 instance profile name"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "cloudwatch_role_arn" {
  description = "ARN of the CloudWatch logging role"
  value       = aws_iam_role.cloudwatch_role.arn
}