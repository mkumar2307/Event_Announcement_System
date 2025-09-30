output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = "${aws_api_gateway_rest_api.event_api.execution_arn}/events"
}

output "sns_topic_arn" {
  value = aws_sns_topic.event_topic.arn
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.event_table.name
}
