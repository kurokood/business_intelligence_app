# QuickSight Module Variables

variable "quicksight_user" {
  description = "QuickSight user name for dashboard permissions"
  type        = string
}

variable "glue_database_name" {
  description = "Name of the Glue database"
  type        = string
}

variable "glue_table_name" {
  description = "Name of the Glue table"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}