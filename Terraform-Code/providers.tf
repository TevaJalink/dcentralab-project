terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.50.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.1"
    }
  }
  backend "s3" {
    bucket         = "dcentralab-hw-project"
    key            = "prod/dcentralab.tfstate"
    region         = "us-east-1"
    dynamodb_table = "dcentralab-table"
  }
}

provider "aws" {
  region     = var.aws_region
}

data "aws_caller_identity" "current" {}