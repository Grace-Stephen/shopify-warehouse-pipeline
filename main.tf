module "iam" {
  source = "./modules/iam"

  project_prefix = var.project_prefix
  raw_bucket_arn          = module.s3.raw_bucket_arn
  glue_scripts_bucket_arn = module.s3.glue_scripts_bucket_arn
  cloudtrail_logs_bucket_name    = module.s3.cloudtrail_logs_bucket_name
  aws_region     = var.aws_region
}

module "s3" {
  source         = "./modules/s3"
  project_prefix = var.project_prefix
}

module "lambda" {
  source       = "./modules/lambda"
  project_prefix   = var.project_prefix
  lambda_role_arn  = module.iam.lambda_role_arn
  raw_bucket_name  = module.s3.raw_bucket_name
  lambda_artifacts_bucket = module.s3.lambda_artifacts_bucket_name
  lambda_zip_key          = "lambda.zip"
}

module "network" {
  source = "./modules/network"
  project_prefix   = var.project_prefix
  az1 = "us-east-1a"
  az2 = "us-east-1b"
}

module "redshift" {
  source = "./modules/redshift"

  project_prefix    = var.project_prefix
  admin_username   = var.admin_username
  master_password   = var.master_password
  redshift_role_arn = module.iam.redshift_role_arn
  private_subnet_ids = module.network.private_subnet_ids
  security_group_ids  = [module.network.redshift_sg_id]
}

module "glue" {
  source              = "./modules/glue"
  project_prefix      = var.project_prefix
  scripts_bucket      = module.s3.glue_scripts_bucket_name
  raw_bucket          = module.s3.raw_bucket_name
  glue_role_arn       = module.iam.glue_role_arn
  eventbridge_role_arn = module.iam.eventbridge_role_arn
  # eventbridge_role_dependencies = [
  #   module.iam   # forces ordering
  # ]
  redshift_namespace  = module.redshift.redshift_namespace_name
  redshift_workgroup  = module.redshift.redshift_workgroup_name
  redshift_admin_username = module.redshift.redshift_admin_username
  redshift_admin_password = module.redshift.redshift_admin_password
  redshift_endpoint = module.redshift.redshift_endpoint
  private_subnet_1_id = module.network.private_subnet_1_id
  private_subnet_1_az = module.network.private_subnet_1_az
  redshift_sg_id     = module.network.redshift_sg_id
  glue_security_group_ids = [module.network.glue_sg_id]
  redshift_db         = "dev"
  redshift_port     = 5439
  redshift_table      = "users_data"
  aws_region           = var.aws_region
}

module "eventbridge" {
  source              = "./modules/eventbridge"
  project_prefix       = var.project_prefix
  aws_region           = var.aws_region
  account_id           = data.aws_caller_identity.current.account_id
  raw_bucket_name      = module.s3.raw_bucket_name
  eventbridge_role_arn = module.iam.eventbridge_role_arn
  glue_workflow_name   = module.glue.glue_workflow_name
  lambda_function_arn  = module.lambda.lambda_function_arn
  lambda_function_name = module.lambda.lambda_function_name
}

module "cloudtrail" {
  source                     = "./modules/cloudtrail"
  project_prefix              = var.project_prefix
  raw_bucket_name             = module.s3.raw_bucket_name
  cloudtrail_logs_bucket_name = module.s3.cloudtrail_logs_bucket_name
}

data "aws_caller_identity" "current" {}
