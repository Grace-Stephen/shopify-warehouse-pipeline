terraform {
  backend "s3" {
    bucket         = "shopify-tfstate-bucket"
    key            = "terraform/state"
    region         = "us-east-1"
    dynamodb_table = "shopify-tf-locks"
    encrypt        = true
  }
}
