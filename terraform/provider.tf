provider "aws" {
  region = "us-east-1" # Change to your desired AWS region
}

terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket" # Replace with your S3 bucket name
    key            = "terraform/state.tfstate"   # Replace with your desired state file path
    region         = "us-east-1"                 # AWS region for the bucket
    encrypt        = true                          # Encrypt the state file
    dynamodb_table = "terraform-lock"            # Optional, for state locking (use DynamoDB)
  }
}

# Example resource to test the configuration
resource "aws_s3_bucket" "example" {
  bucket = "example-bucket-name"
  acl    = "private"
}