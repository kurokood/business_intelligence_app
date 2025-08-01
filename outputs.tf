# Serverless Architecture Outputs

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.s3.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.s3.bucket_arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = module.lambda.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = module.lambda.function_arn
}

output "glue_database_name" {
  description = "Name of the Glue database"
  value       = module.glue.database_name
}

output "glue_table_name" {
  description = "Name of the Glue table"
  value       = module.glue.table_name
}

output "glue_job_name" {
  description = "Name of the Glue job"
  value       = module.glue.job_name
}

output "schedule_rule_name" {
  description = "Name of the EventBridge schedule rule"
  value       = module.lambda.schedule_rule_name
}

output "api_gateway_url" {
  description = "URL to manually trigger data generation"
  value       = "https://${aws_api_gateway_rest_api.lambda_api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.prod.stage_name}/generate"
}

output "architecture_summary" {
  description = "Summary of the serverless architecture"
  value = {
    compute_model    = "Serverless (Lambda)"
    scheduling       = "EventBridge (every 5 minutes)"
    network_required = "None"
    cost_model       = "Pay-per-execution"
    maintenance      = "Zero"
    modules_count    = "4 (vs 7 with EC2)"
  }
}