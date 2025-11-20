# resource "aws_redshift_subnet_group" "this" {
#   name       = "${var.project_prefix}-subnet-group"
#   description = "Subnet group for Redshift cluster"
#   subnet_ids  = var.private_subnet_ids
# }

# resource "aws_security_group" "redshift_sg" {
#   name        = "${var.project_prefix}-redshift-sg"
# #   description = "Security group for Redshift cluster"
#   vpc_id      = var.vpc_id

#   ingress {
#     from_port   = 5439
#     to_port     = 5439
#     protocol    = "tcp"
#     # Allow Glue, Lambda, or admin IP (optional)
#     # security_groups = [var.glue_sg_id]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "${var.project_prefix}-redshift-sg"
#   }
# }

# resource "aws_redshift_cluster" "this" {
#   cluster_identifier       = "${var.project_prefix}-redshift-cluster"
#   node_type                = "dc2.large"
#   number_of_nodes          = 1
#   database_name            = var.db_name
#   master_username          = var.master_username
#   master_password          = var.master_password
#   iam_roles                = [var.redshift_role_arn]

#   cluster_subnet_group_name = aws_redshift_subnet_group.this.name
#   vpc_security_group_ids    = [aws_security_group.redshift_sg.id]
#   publicly_accessible       = false

#   skip_final_snapshot       = true

#   tags = {
#     Environment = "dev"
#     Project     = var.project_prefix
#   }
# }


#REDSHIFT SERVERLESS

resource "aws_redshiftserverless_namespace" "this" {
  namespace_name = "${var.project_prefix}-namespace"
  admin_username = var.admin_username
  admin_user_password = var.master_password
  iam_roles = [var.redshift_role_arn]

  log_exports = ["userlog", "connectionlog", "useractivitylog"]
}

resource "aws_redshiftserverless_workgroup" "this" {
  workgroup_name = "${var.project_prefix}-workgroup"
  namespace_name = aws_redshiftserverless_namespace.this.namespace_name

  base_capacity = 8 # 8 RPU is the minimum for most workloads

  subnet_ids = var.private_subnet_ids
  security_group_ids = var.security_group_ids

  publicly_accessible = false

  tags = {
    Project = var.project_prefix
    Env     = "dev"
  }
}

