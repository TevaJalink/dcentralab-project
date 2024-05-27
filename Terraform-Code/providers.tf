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
  assume_role {
    role_arn = "arn:aws:iam::654654442933:role/dcentralab-project-oidc-github-actions"
  }
}

data "aws_caller_identity" "current" {}