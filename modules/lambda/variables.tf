# Lambda Module Variables
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "lambda_role_arn" {
  description = "ARN of the Lambda execution role"
  type        = string
}

variable "ssm_parameter_name" {
  description = "Name of the SSM parameter containing bucket name"
  type        = string
  default     = "clickstream_bucket"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "lambda_schedule" {
  description = "EventBridge schedule expression for Lambda"
  type        = string
  default     = "rate(5 minutes)"
}

variable "events_per_execution" {
  description = "Number of events to generate per Lambda execution"
  type        = number
  default     = 20
}