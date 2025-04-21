output "api_url" {
  description = "Base URL of the API Gateway"
  value       = "https://${aws_api_gateway_rest_api.todo_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_api_gateway_stage.todo_api.stage_name}"
}

output "api_id" {
  description = "ID of the API Gateway REST API"
  value       = aws_api_gateway_rest_api.todo_api.id
}

output "api_stage_name" {
  description = "Name of the API Gateway stage"
  value       = aws_api_gateway_stage.todo_api.stage_name
}

output "api_endpoint" {
  description = "Full endpoint URL of the API"
  value       = "https://${aws_api_gateway_rest_api.todo_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_api_gateway_stage.todo_api.stage_name}"
}