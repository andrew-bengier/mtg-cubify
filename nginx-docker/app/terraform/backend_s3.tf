terraform {
  backend "s3" {
    bucket = "bnfd-terraform-state-files"
    key = "nginx-docker"
    region = "us-east-1"
  }
}