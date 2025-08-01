# Glue Module Outputs
output "database_name" {
  description = "Name of the Glue database"
  value       = aws_glue_catalog_database.clickstream_db.name
}

output "table_name" {
  description = "Name of the Glue table"
  value       = aws_glue_catalog_table.clickstream_table.name
}

output "job_name" {
  description = "Name of the Glue job"
  value       = aws_glue_job.clickstream_job.name
}