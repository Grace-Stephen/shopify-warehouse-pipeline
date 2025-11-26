Shopify Warehouse Data Pipeline — Fully Automated Serverless ETL on AWS

Overview

This project implements a fully automated, end-to-end serverless data pipeline that ingests product data from the Shopify API using AWS Lambda, processes and transforms it using AWS AWS Glue, loads structured data into Amazon Redshift, and makes it immediately ready for analytics in Amazon QuickSight.

Unlike the earlier CSV-based pipeline, which required manual S3 uploads and manually triggering Glue jobs, this pipeline is 100% event-driven, fully modular, and production-grade.

Infrastructure is provisioned using Terraform, and deployment is automated using GitHub Actions with OIDC (no long-lived access keys). The workflow includes Lambda packaging, S3 artifact management, Redshift credential handling, and complete infra deployment.

This pipeline demonstrates scalable warehouse ingestion for real Shopify datasets with no human intervention.

Key Differences from the AWS CSV Pipeline

1. No manual file upload
Lambda automatically requests product data from the Shopify API and stores the raw file in S3. No human upload required.

2. No manual Glue trigger
S3 → CloudTrail → EventBridge automatically triggers the Glue workflow.
Glue crawlers and jobs run automatically.

3. No manifest.json required for QuickSight
Since transformed data lands in Redshift, QuickSight connects directly without bucket-level manifest files.

4. OIDC used for CI/CD (no access keys)
GitHub Actions authenticates to AWS through OpenID Connect, avoiding long-lived credentials.

5. Strict least-privilege IAM
IAM roles and policies were redesigned for minimal permissions across Lambda, Glue, S3, EventBridge, and Redshift.

6. CloudTrail used to capture S3 data events for EventBridge
S3 → EventBridge notifications were unreliable without CloudTrail because EventBridge requires CloudTrail data events to detect object-level S3 actions reliably.

7. Fully modular Terraform architecture
Each AWS service—S3, Lambda, Glue, IAM, Redshift, Network, EventBridge, CloudTrail—exists in its own module with no cross-resource leakage.

8. CI/CD also packages Lambda code
GitHub Actions builds lambda.zip, uploads it to a dedicated Lambda artifact bucket, and Terraform deploys it.

9. GitHub Secrets store Redshift credentials and Lambda bucket details
This enables secure deployment and script updates.


Architecture Summary

The pipeline consists of tightly integrated AWS components:

1. Shopify → Lambda Ingestion

- EventBridge triggers the Lambda function.

- Lambda calls Shopify API and fetches inventory/product data.

- The Lambda function writes raw JSON data to Amazon S3.

2. CloudTrail + EventBridge Automation

S3 alone cannot reliably emit object-level events to EventBridge.
Therefore:

- CloudTrail captures PutObject events for the raw bucket.

- CloudTrail forwards these data events to EventBridge.

- EventBridge rule then triggers the Glue workflow.

This reliably ensures automation for every new dataset dropped by Lambda.

3. AWS Glue Workflow

The Glue workflow:

- Runs a crawler on the raw S3 data 

- Executes a Glue ETL job to transform and load structured data into Redshift.

4. Amazon Redshift

Fully transformed data lands in Redshift in a query-ready format.

5. QuickSight Integration

Since Redshift is the final data store:

- No manifest.json is required.

- Connecting QuickSight to Redshift enables instant analytics.

Tools and Technologies
- Terraform for Infrastructure as Code.
- GitHub Actions (OIDC authentication) for CI/CD automation
- EventBridge for event orchestration
- Cloudtrail for audit and notification
- AWS Lambda for serverless compute
- Amazon S3 for storage
- AWS Glue for data transformation
- Amazon Redshift for data warehouse
- Amazon QuickSight for data visualization
- Python as programming language for Lambda and Glue

CI/CD Workflow Summary
1. OIDC Authentication (No Secrets for AWS Access)

GitHub Actions uses federated identity to request temporary AWS credentials.

2. Targeted s3 module deployment

for a successful deployment of Lambda via CICD, lambda code must be zipped and uploaded to a dedicated s3 bucket. So s3 module had to be deployed before the rest of the infrastructure.

3. Lambda Packaging Stage

The workflow:

- Builds and packages lambda code + dependencies into lambda.zip.

- Uploads the zip to a dedicated S3 Lambda artifact bucket.

- Terraform references this artifact as the Lambda source.

4. The rest of the infra is deployed

On each push:

- terraform init

- terraform plan

- terraform apply (for main branch only)

Terraform provisions:

- IAM roles for Lambda, Glue, RedShift, EventBridge and QuickSight

- Lambda function + code

- CloudTrail with S3 data event selectors

- EventBridge rule + targets

- Glue crawler, job, and workflow

- VPC networking resources

- Redshift serverless

5. Secrets Management

GitHub Secrets store:

- Redshift admin username

- Redshift master password

- Lambda artifact bucket name

- AWS account id

No AWS access keys are stored.


Learning Highlights

This project deepened understanding of:

- Complex event-driven architecture with CloudTrail + EventBridge

- Modular, scalable Terraform design

- Using OIDC for secure CI/CD 

- Advanced IAM least-privilege permissioning

- Managing Lambda artifacts through S3 for production pipelines

- Implementing Glue workflows with chained crawlers + ETL jobs

- Automating warehouse ingestion into Redshift

- Establishing VPC connection between Redshift and QuickSight

- Debugging AWS service interactions across logs, CloudTrail, and EventBridge

Conclusion

This project represents a fully automated, production-grade Shopify data ingestion and warehousing pipeline. It replaces manual uploads, manual triggers, and console-based execution with a complete end-to-end event-driven workflow.

With strict IAM policies, modular Terraform design, secure OIDC-based CI/CD, and reliable event orchestration through CloudTrail + EventBridge, this system demonstrates real-world data engineering and DevOps capability for cloud-native ETL pipelines.