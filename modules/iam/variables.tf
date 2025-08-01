# IAM Module Variables
variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}