data "aws_caller_identity" "current" {}


# ========== UPLOAD SCRIPT TO S3 ==========
resource "aws_s3_object" "glue_script" {
  bucket = var.scripts_bucket
  key    = "scripts/transform.py"
  source = "${path.module}/scripts/transform.py"
  etag   = filemd5("${path.module}/scripts/transform.py")
}

# ========== GLUE DATABASE ==========
resource "aws_glue_catalog_database" "this" {
  name = "${var.project_prefix}_db"
}

# ========== GLUE CRAWLER ==========
resource "aws_glue_crawler" "raw_data_crawler" {
  name         = "${var.project_prefix}-raw-data-crawler"
  role         = var.glue_role_arn
  database_name = aws_glue_catalog_database.this.name
  table_prefix = "raw_"

  s3_target {
    path = "s3://${var.raw_bucket}/"
  }

  configuration = jsonencode({
    Version = 1.0
    CrawlerOutput = {
      Partitions = { AddOrUpdateBehavior = "InheritFromTable" }
    }
  })

  schedule = null

  depends_on = [aws_glue_catalog_database.this]
}

# ========== GLUE JOB ==========
resource "aws_glue_job" "transform_job" {
  name     = "${var.project_prefix}-transform-job"
  role_arn = var.glue_role_arn
  connections = [aws_glue_connection.redshift_serverless.name]

  command {
    name            = "glueetl"
    script_location = "s3://${var.scripts_bucket}/scripts/transform.py"
    python_version  = "3"
  }

  default_arguments = {
    "--TempDir"              = "s3://${var.scripts_bucket}/temp/"
    "--raw_bucket"           = var.raw_bucket
    "--redshift_workgroup"   = var.redshift_workgroup
    "--redshift_db"          = var.redshift_db
    "--redshift_table"       = var.redshift_table
    "--redshift_temp_dir"    = "s3://${var.scripts_bucket}/temp/"
    "--job-language"         = "python"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-metrics"       = "true"
  }

  glue_version = "4.0"
  max_retries  = 1
  timeout      = 10
  number_of_workers = 2
  worker_type = "G.1X"

  depends_on = [aws_s3_object.glue_script]
}


resource "aws_glue_workflow" "this" {
  name = "${var.project_prefix}-workflow"
}

# Glue trigger for the crawler
resource "aws_glue_trigger" "crawler_trigger" {
  name          = "${var.project_prefix}-crawler-trigger"
  type          = "EVENT"
  workflow_name = aws_glue_workflow.this.name

  actions {
    crawler_name = aws_glue_crawler.raw_data_crawler.name
  }
}

# Glue trigger for the transform job
resource "aws_glue_trigger" "job_trigger" {
  name          = "${var.project_prefix}-job-trigger"
  type          = "CONDITIONAL"
  workflow_name = aws_glue_workflow.this.name

  predicate {
    conditions {
      crawl_state = "SUCCEEDED"
      crawler_name = aws_glue_crawler.raw_data_crawler.name
    }
  }

  actions {
    job_name = aws_glue_job.transform_job.name
  }
}


#Glue Connection to RedShift Serverless
resource "aws_glue_connection" "redshift_serverless" {
  name = "redshift-serverless"

  connection_type = "JDBC"

  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:redshift://${var.redshift_endpoint}:${var.redshift_port}/${var.redshift_db}"
    USERNAME            = var.redshift_admin_username
    PASSWORD            = var.redshift_admin_password
  }

  physical_connection_requirements {
    subnet_id              = var.private_subnet_1_id
    availability_zone      = var.private_subnet_1_az
    # security_group_id_list = [var.redshift_sg_id]
    security_group_id_list   = var.glue_security_group_ids
  }
}


# Allow EventBridge to trigger Glue workflows
resource "aws_glue_resource_policy" "allow_eventbridge" {
  depends_on = [
    modules.iam.eventbridge_role
  ]
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid: "AllowEventBridgeToStartWorkflow",
        Effect: "Allow",
        Principal: {
          AWS: module.iam.eventbridge_role
        },
        Action: [
          "glue:StartWorkflowRun",
          "glue:StartJobRun",
          "glue:StartCrawler"
        ],
        Resource = "arn:aws:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:workflow/${var.project_prefix}-workflow"
      }
    ]
  })
}
