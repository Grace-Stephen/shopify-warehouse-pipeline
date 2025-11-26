data "aws_caller_identity" "current" {}

###########################################

# IAM Role for Lambda

###########################################

resource "aws_iam_role" "lambda_role" {
name = "${var.project_prefix}-Lambda-S3-Glue-Role"

assume_role_policy = jsonencode({
Version = "2012-10-17"
Statement = [
{
Effect = "Allow"
Principal = {
Service = "lambda.amazonaws.com"
}
Action = "sts:AssumeRole"
}
]
})
}

# Attach policies to Lambda role

# Custom policy limiting Lambda S3 access to only specific buckets
resource "aws_iam_policy" "lambda_s3_policy" {
  name = "${var.project_prefix}-Lambda-S3-Policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
  var.raw_bucket_arn,
  "${var.raw_bucket_arn}/*"
]
      }
    ]
  })
}

# Attach the custom S3 policy to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_s3_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
}

#other policies
resource "aws_iam_role_policy_attachment" "lambda_glue_access" {
role       = aws_iam_role.lambda_role.name
policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
role       = aws_iam_role.lambda_role.name
policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

###########################################

# IAM Role for Glue

###########################################

resource "aws_iam_role" "glue_role" {
name = "${var.project_prefix}-Glue-Service-Role"

assume_role_policy = jsonencode({
Version = "2012-10-17"
Statement = [
{
Effect = "Allow"
Principal = {
Service = "glue.amazonaws.com"
}
Action = "sts:AssumeRole"
}
]
})
}

# Attach policies to Glue role

# --- Custom Policy for Glue S3 Access ---
resource "aws_iam_policy" "glue_s3_policy" {
  name = "${var.project_prefix}-Glue-S3-Policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Read data from raw S3 bucket
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
  var.raw_bucket_arn,
  "${var.raw_bucket_arn}/*"
]
      },
      # Write temporary or transformed data to Glue scripts bucket
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          var.glue_scripts_bucket_arn,
          "${var.glue_scripts_bucket_arn}/*"
        ]
      }
    ]
  })
}

# --- Attach Policies to Glue Role ---
resource "aws_iam_role_policy_attachment" "glue_s3_policy_attach" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_s3_policy.arn
}

#other policies
resource "aws_iam_role_policy_attachment" "glue_service_access" {
role       = aws_iam_role.glue_role.name
policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy_attachment" "glue_redshift_access" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRedshiftFullAccess"
}

resource "aws_iam_role_policy_attachment" "glue_cloudwatch_logs" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}


############################################

###########################################
# IAM Role for EventBridge to trigger Lambda and Glue
#####################################################

resource "aws_iam_role" "eventbridge_role" {
  name = "${var.project_prefix}-EventBridge-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "eventbridge_policy" {
  name = "${var.project_prefix}-EventBridge-Policy"
  role = aws_iam_role.eventbridge_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction",  # ✅ added
          "glue:StartWorkflowRun",
          "glue:StartJobRun",
          "glue:StartCrawler",
          "glue:NotifyEvent"
        ]
        Resource = "*"
      }
    ]
  })
}


###########################################
# IAM Role for Redshift
###########################################

resource "aws_iam_role" "redshift_role" {
  name = "${var.project_prefix}-Redshift-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "redshift.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "redshift_s3_access" {
  role       = aws_iam_role.redshift_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

#CLOUDTRAIL BUCKET POLICY
resource "aws_s3_bucket_policy" "cloudtrail_logs_policy" {
  bucket = var.cloudtrail_logs_bucket_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AWSCloudTrailAclCheck"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = "arn:aws:s3:::${var.cloudtrail_logs_bucket_name}"
      },
      {
        Sid       = "AWSCloudTrailWrite"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "arn:aws:s3:::${var.cloudtrail_logs_bucket_name}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

#IAM ROLE FOR QUICKSIGHT
resource "aws_iam_role" "quicksight_vpc_role" {
  name = "${var.project_prefix}-quicksight-vpc-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "quicksight.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "quicksight_vpc_policy" {
  name        = "${var.project_prefix}-quicksight-vpc-policy"
  description = "Allow QuickSight to access VPC resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeRouteTables",
          "ec2:DescribeInternetGateways",
          "ec2:CreateTags",
          "ec2:DescribeAvailabilityZones"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "quicksight_attach_policy" {
  role       = aws_iam_role.quicksight_vpc_role.name
  policy_arn = aws_iam_policy.quicksight_vpc_policy.arn
}

# Allow EventBridge to trigger Glue workflows
resource "aws_glue_resource_policy" "allow_eventbridge" {
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

