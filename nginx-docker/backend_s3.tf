terraform {
  backend "s3" {
    profile = "bnfd-abengier"
    bucket  = "bnfd-terraform-state-files"
    key     = "bnfd-ecs-example"
    region  = "us-east-1"
  }
}
