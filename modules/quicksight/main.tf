# QuickSight Module for Business Intelligence Dashboards

# Data source for current AWS account
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Note: QuickSight resources via Terraform can be complex and often require
# manual setup through the QuickSight console for full dashboard functionality.
# This module provides the foundation and instructions for manual setup.

# Output instructions for QuickSight setup
locals {
  setup_instructions = <<-EOT
    QuickSight Setup Instructions:
    
    1. Enable QuickSight in your AWS account (if not already enabled)
    2. Go to AWS QuickSight console: https://${data.aws_region.current.name}.quicksight.aws.amazon.com
    3. Create a new Data Source:
       - Type: Athena
       - Name: "Clickstream Athena Data Source"
       - Workgroup: primary
    4. Create a new Dataset:
       - Source: Athena data source created above
       - Database: ${var.glue_database_name}
       - Table: ${var.glue_table_name}
       - Import to SPICE: Yes (for better performance)
    5. Create Analysis with these visualizations:
       - Bar Chart: Events by Country (country-name vs count)
       - Line Chart: Events Over Time (click-date vs count)
       - Pie Chart: Event Type Distribution (event_type)
       - Geospatial Map: Global Event Distribution (country-name)
       - Histogram: User Age Distribution (user_age)
       - Stacked Bar: User Actions by Product Category
    6. Publish as Dashboard for business users
    7. Set up automatic refresh schedule (hourly/daily)
    8. Share with business stakeholders
    
    Sample Visualizations:
    - Executive KPIs: Total events, unique users, top countries
    - Geographic Analysis: World map with click-through rates
    - User Behavior: Age demographics, action patterns
    - Product Performance: Category engagement metrics
    - Time Series: Hourly/daily trends and patterns
  EOT

  quicksight_console_url = "https://${data.aws_region.current.name}.quicksight.aws.amazon.com/sn/start"
  
  dashboard_examples = {
    executive_summary = {
      title = "Executive Summary Dashboard"
      visuals = [
        "Total Events (KPI)",
        "Unique Users (KPI)", 
        "Top 10 Countries (Bar Chart)",
        "Events Over Time (Line Chart)"
      ]
    }
    geographic_analysis = {
      title = "Geographic Analysis Dashboard"
      visuals = [
        "World Map (Geospatial)",
        "Events by Continent (Pie Chart)",
        "Country Performance (Table)",
        "Regional Trends (Line Chart)"
      ]
    }
    user_behavior = {
      title = "User Behavior Dashboard"
      visuals = [
        "Age Distribution (Histogram)",
        "User Actions (Funnel Chart)",
        "Product Categories (Stacked Bar)",
        "Event Types (Donut Chart)"
      ]
    }
  }
}