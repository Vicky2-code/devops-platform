terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment once you have real state storage (never keep tfstate on disk for prod)
  # backend "s3" {
  #   bucket = "devflow-tfstate"
  #   key    = "devflow/terraform.tfstate"
  #   region = "us-east-1"
  #   dynamodb_table = "devflow-tfstate-lock"
  # }
}

provider "aws" {
  region = var.region
}

locals {
  name = "devflow"
}