# Lambda Module Outputs
output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.clickstream_generator.function_name
}

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.clickstream_generator.arn
}

output "schedule_rule_name" {
  description = "Name of the EventBridge schedule rule"
  value       = aws_cloudwatch_event_rule.lambda_schedule.name
}