# Data source for AWS account ID
data "aws_caller_identity" "current" {}

# Use a simpler approach to check if instance profile exists
locals {
  instance_profile_exists = true  # Default to assuming it exists to avoid creation errors
  instance_profile_name = "${var.project_name}-ec2-profile"
}

# EC2 instance profile for Docker host - disabled since resource exists
resource "aws_iam_role" "ec2_role" {
  count = 0  # Disable creation as resource exists
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-ec2-role"
  }
}

# Only create the instance profile if we explicitly set the local to false
resource "aws_iam_instance_profile" "ec2_profile" {
  count = local.instance_profile_exists ? 0 : 1
  name = local.instance_profile_name
  # Reference the role directly by name since we know it exists
  role = "${var.project_name}-ec2-role"
}

# Attach SSM policy to EC2 role for easier management
resource "aws_iam_role_policy_attachment" "ec2_ssm_attachment" {
  # Reference the role directly by name since we know it exists
  role       = "${var.project_name}-ec2-role"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Custom policy for EC2 permissions
resource "aws_iam_policy" "ec2_policy" {
  count       = 0  # Disable creation as resource exists
  name        = "${var.project_name}-ec2-policy"
  description = "Custom policy for EC2 instance"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeImages",
          "ec2:DescribeTags",
          "ec2:DescribeSnapshots"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Attach custom EC2 policy
resource "aws_iam_role_policy_attachment" "ec2_policy_attachment" {
  # Reference the role and policy directly by name
  role       = "${var.project_name}-ec2-role"
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${var.project_name}-ec2-policy"
}

# Create IAM role for CloudWatch logging for API Gateway
resource "aws_iam_role" "cloudwatch_role" {
  count = 0  # Disable creation as resource exists
  name = "${var.project_name}-cloudwatch-role"

  # Update the assume role policy to allow API Gateway to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "apigateway.amazonaws.com",
            "ec2.amazonaws.com"
          ]
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-cloudwatch-role"
  }
}

# Attach CloudWatch policy to role with proper permissions for API Gateway
resource "aws_iam_role_policy" "cloudwatch_policy" {
  name = "${var.project_name}-cloudwatch-policy"
  # Reference the role directly by name
  role = "${var.project_name}-cloudwatch-role"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ]
        Effect = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Add the specific API Gateway CloudWatch role policy
resource "aws_iam_role_policy_attachment" "gateway_cloudwatch_policy" {
  # Reference the role directly by name
  role       = "${var.project_name}-cloudwatch-role"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}