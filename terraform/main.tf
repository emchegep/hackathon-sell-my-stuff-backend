provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = "devops-skool-tf-states"
    key    = "sell-my-stuff-backend/terraform.tfstate"
    region = "us-east-2"
  }
}
