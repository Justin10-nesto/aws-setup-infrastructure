// Get current AWS region for API URL construction
data "aws_region" "current" {}

# Add data source to get AWS account ID
data "aws_caller_identity" "current" {}

resource "aws_api_gateway_rest_api" "todo_api" {
    name        = "${var.project_name}-api"
    description = "API Gateway for ToDo App"

    endpoint_configuration {
        types = ["REGIONAL"]
    }
}

# Root path resource - for redirection to EC2 instance
resource "aws_api_gateway_resource" "proxy" {
    rest_api_id = aws_api_gateway_rest_api.todo_api.id
    parent_id   = aws_api_gateway_rest_api.todo_api.root_resource_id
    path_part   = "{proxy+}"
}

# ANY method for proxy resource - catch all requests
resource "aws_api_gateway_method" "proxy_method" {
    rest_api_id   = aws_api_gateway_rest_api.todo_api.id
    resource_id   = aws_api_gateway_resource.proxy.id
    http_method   = "ANY"
    authorization = "NONE"

    request_parameters = {
        "method.request.path.proxy" = true
    }
}

# Integration with EC2 instance - HTTP_PROXY to forward requests
resource "aws_api_gateway_integration" "proxy_integration" {
    rest_api_id             = aws_api_gateway_rest_api.todo_api.id
    resource_id             = aws_api_gateway_resource.proxy.id
    http_method             = aws_api_gateway_method.proxy_method.http_method
    integration_http_method = "ANY"
    type                    = "HTTP_PROXY"
    uri                     = "http://${var.ec2_endpoint}/{proxy}"
    connection_type         = "INTERNET"

    request_parameters = {
        "integration.request.path.proxy" = "method.request.path.proxy"
    }
}

# Root method to handle requests to base path
resource "aws_api_gateway_method" "root_method" {
    rest_api_id   = aws_api_gateway_rest_api.todo_api.id
    resource_id   = aws_api_gateway_rest_api.todo_api.root_resource_id
    http_method   = "ANY"
    authorization = "NONE"
}

# Root integration to forward to EC2
resource "aws_api_gateway_integration" "root_integration" {
    rest_api_id             = aws_api_gateway_rest_api.todo_api.id
    resource_id             = aws_api_gateway_rest_api.todo_api.root_resource_id
    http_method             = aws_api_gateway_method.root_method.http_method
    integration_http_method = "ANY"
    type                    = "HTTP_PROXY"
    uri                     = "http://${var.ec2_endpoint}/"
    connection_type         = "INTERNET"
}

# API Gateway deployment
resource "aws_api_gateway_deployment" "todo_api" {
    rest_api_id = aws_api_gateway_rest_api.todo_api.id
  
    triggers = {
        # Force redeployment when API resources or methods are changed
        redeployment = sha1(jsonencode([
            aws_api_gateway_resource.proxy,
            aws_api_gateway_method.proxy_method,
            aws_api_gateway_integration.proxy_integration,
            aws_api_gateway_method.root_method,
            aws_api_gateway_integration.root_integration
        ]))
    }
  
    lifecycle {
        create_before_destroy = true
    }
  
    depends_on = [
        aws_api_gateway_integration.proxy_integration,
        aws_api_gateway_integration.root_integration
    ]
}

# Configure API Gateway account-level settings for CloudWatch logs
resource "aws_api_gateway_account" "this" {
    cloudwatch_role_arn = var.cloudwatch_role_arn
}

# Check if CloudWatch log group already exists
data "aws_cloudwatch_log_group" "existing_log_group" {
    name = "/aws/apigateway/${var.project_name}-api"
    count = 0  # Set to 0 to prevent errors if not found, but keep the resource defined
}

# CloudWatch log group for API Gateway with conditional creation
resource "aws_cloudwatch_log_group" "api_gateway_logs" {
    # Skip creation if log group exists (will be handled by import)
    count             = 0
    name              = "/aws/apigateway/${var.project_name}-api"
    retention_in_days = 7
}

# API Gateway stage
resource "aws_api_gateway_stage" "todo_api" {
    deployment_id = aws_api_gateway_deployment.todo_api.id
    rest_api_id   = aws_api_gateway_rest_api.todo_api.id
    stage_name    = var.api_stage_name
  
    access_log_settings {
        # Use the CloudWatch log group ARN format directly since we know it exists
        destination_arn = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/apigateway/${var.project_name}-api"
        format          = jsonencode({
            requestId      = "$context.requestId"
            ip             = "$context.identity.sourceIp"
            caller         = "$context.identity.caller"
            user           = "$context.identity.user"
            requestTime    = "$context.requestTime"
            httpMethod     = "$context.httpMethod"
            resourcePath   = "$context.resourcePath"
            status         = "$context.status"
            protocol       = "$context.protocol"
            responseLength = "$context.responseLength"
        })
    }
  
    depends_on = [aws_api_gateway_account.this]
}

# Enable CORS for the proxy resource
resource "aws_api_gateway_method_response" "proxy_cors" {
    rest_api_id = aws_api_gateway_rest_api.todo_api.id
    resource_id = aws_api_gateway_resource.proxy.id
    http_method = aws_api_gateway_method.proxy_method.http_method
    status_code = "200"

    response_parameters = {
        "method.response.header.Access-Control-Allow-Origin"  = true,
        "method.response.header.Access-Control-Allow-Methods" = true,
        "method.response.header.Access-Control-Allow-Headers" = true
    }

    depends_on = [aws_api_gateway_method.proxy_method]
}

# OPTIONS method for CORS support
resource "aws_api_gateway_method" "options_method" {
    rest_api_id   = aws_api_gateway_rest_api.todo_api.id
    resource_id   = aws_api_gateway_resource.proxy.id
    http_method   = "OPTIONS"
    authorization = "NONE"
}

# OPTIONS method integration
resource "aws_api_gateway_integration" "options_integration" {
    rest_api_id = aws_api_gateway_rest_api.todo_api.id
    resource_id = aws_api_gateway_resource.proxy.id
    http_method = aws_api_gateway_method.options_method.http_method
    type        = "MOCK"
    
    request_templates = {
        "application/json" = "{\"statusCode\": 200}"
    }
}

# Response for OPTIONS method
resource "aws_api_gateway_method_response" "options_response" {
    rest_api_id = aws_api_gateway_rest_api.todo_api.id
    resource_id = aws_api_gateway_resource.proxy.id
    http_method = aws_api_gateway_method.options_method.http_method
    status_code = "200"

    response_parameters = {
        "method.response.header.Access-Control-Allow-Origin"  = true,
        "method.response.header.Access-Control-Allow-Methods" = true,
        "method.response.header.Access-Control-Allow-Headers" = true
    }

    depends_on = [aws_api_gateway_method.options_method]
}

# Integration response for OPTIONS
resource "aws_api_gateway_integration_response" "options_integration_response" {
    rest_api_id = aws_api_gateway_rest_api.todo_api.id
    resource_id = aws_api_gateway_resource.proxy.id
    http_method = aws_api_gateway_method.options_method.http_method
    status_code = aws_api_gateway_method_response.options_response.status_code

    response_parameters = {
        "method.response.header.Access-Control-Allow-Origin"  = "'*'",
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
        "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
    }

    depends_on = [
        aws_api_gateway_method_response.options_response,
        aws_api_gateway_integration.options_integration
    ]
}