# QuickSight Module Outputs

# QuickSight resources are set up manually through the console
# These outputs provide the necessary information for setup

output "setup_instructions" {
  description = "Instructions for setting up QuickSight dashboards"
  value       = local.setup_instructions
}

output "quicksight_console_url" {
  description = "URL to access QuickSight console for dashboard creation"
  value       = local.quicksight_console_url
}

output "dashboard_examples" {
  description = "Example dashboard configurations for business users"
  value       = local.dashboard_examples
}

output "glue_database_name" {
  description = "Glue database name for QuickSight data source"
  value       = var.glue_database_name
}

output "glue_table_name" {
  description = "Glue table name for QuickSight dataset"
  value       = var.glue_table_name
}