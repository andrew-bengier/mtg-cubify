terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.55.0"
    }
  }
  
  required_version = ">= 1.0.0"
}

provider "aws" {
  region                   = "us-east-1"
  profile                  = "bnfd-abengier"
  shared_credentials_files = ["~/.aws/credentials"]

  default_tags {
    tags = {
      project     = "bnfd"
      startedBy   = "Terraform"
      workspace   = terraform.workspace
      environment = terraform.workspace
    }
  }
}


