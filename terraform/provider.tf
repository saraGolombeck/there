provider "aws" {
  region                  = "us-east-1" # AWS region
  shared_credentials_file = "~/.aws/credentials" # Path to AWS credentials file
}

terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket" # S3 bucket name
    key            = "terraform/state.tfstate"   # desired state file path
    region         = "us-east-1"                 # AWS region for the bucket
    encrypt        = true                          # Encrypt the state file
    dynamodb_table = "terraform-lock"            # Optional, for state locking (use DynamoDB) 
  }
}