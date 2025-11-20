# output "redshift_endpoint" {
#   value = aws_redshift_cluster.this.endpoint
# }

# output "redshift_database_name" {
#   value = aws_redshift_cluster.this.database_name
# }

#OUTPUT FOR REDSHIFT SERVERLESS

output "redshift_workgroup_name" {
  value = aws_redshiftserverless_workgroup.this.workgroup_name
}

output "redshift_namespace_name" {
  value = aws_redshiftserverless_namespace.this.namespace_name
}

output "redshift_endpoint" {
  value = aws_redshiftserverless_workgroup.this.endpoint[0].address
}

output "redshift_admin_username" {
  description = "Redshift admin username"
  value       = var.admin_username
}

output "redshift_admin_password" {
  description = "Redshift admin password"
  value       = var.master_password
}