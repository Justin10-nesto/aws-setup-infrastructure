variable "project_name" {
  description = "Project name to use in resource names"
  type        = string
}

variable "ec2_endpoint" {
  description = "The endpoint URL for the EC2 instance running the ToDo app"
  type        = string
}

variable "api_stage_name" {
  description = "Name of the API Gateway stage"
  type        = string
  default     = "v1"
}

variable "cloudwatch_role_arn" {
  description = "ARN of the IAM role for API Gateway to write to CloudWatch logs"
  type        = string
}