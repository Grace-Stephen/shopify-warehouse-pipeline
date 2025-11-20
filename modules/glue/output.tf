output "glue_database_name" {
  value = aws_glue_catalog_database.this.name
}

output "glue_job_name" {
  value = aws_glue_job.transform_job.name
}

output "glue_crawler_name" {
  value = aws_glue_crawler.raw_data_crawler.name
}

output "glue_workflow_name" {
  value = aws_glue_workflow.this.name
}
