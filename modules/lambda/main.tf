# Lambda Module for Clickstream Data Generation

# Create Lambda deployment package
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.root}/lambda_src"
  output_path = "${path.root}/lambda_function.zip"
}

# Lambda function
resource "aws_lambda_function" "clickstream_generator" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "${var.project_name}-clickstream-generator"
  role          = var.lambda_role_arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  timeout       = 300
  memory_size   = 512

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      S3_BUCKET_NAME       = var.s3_bucket_name
      SSM_PARAMETER        = var.ssm_parameter_name
      EVENTS_PER_EXECUTION = var.events_per_execution
    }
  }

  tags = var.common_tags
}

# EventBridge rule to trigger Lambda on schedule
resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  name                = "${var.project_name}-clickstream-schedule"
  description         = "Trigger clickstream generator on schedule: ${var.lambda_schedule}"
  schedule_expression = var.lambda_schedule

  tags = var.common_tags
}

# EventBridge target
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.lambda_schedule.name
  target_id = "ClickstreamGeneratorTarget"
  arn       = aws_lambda_function.clickstream_generator.arn
}

# Lambda permission for EventBridge
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.clickstream_generator.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule.arn
}

# Upload reference data to S3
resource "aws_s3_object" "reference_data" {
  bucket = var.s3_bucket_name
  key    = "reference/countries_continents.csv"
  source = "${path.root}/aux/countries_continents.csv"
  etag   = filemd5("${path.root}/aux/countries_continents.csv")

  tags = var.common_tags
}

# Upload Glue job script
resource "aws_s3_object" "glue_job_script" {
  bucket = var.s3_bucket_name
  key    = "glue-script/job.py"
  source = "${path.root}/aux/job.py"
  etag   = filemd5("${path.root}/aux/job.py")

  tags = var.common_tags
}