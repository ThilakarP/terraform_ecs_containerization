terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.0"
    }
  }

  backend "s3" {
    bucket         = "s3-terraform-thilak"
    key            = "aws/ecs/terraform_ecs.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-dynamodb-thilak1"
  }
}

provider "aws" {
  region = var.project_region
}


data "aws_s3_bucket" "tfstatebucket" {
  bucket = "s3-terraform-thilak"
}

data "aws_dynamodb_table" "tfstatelock" {
  name = "terraform-lock-dynamodb-thilak1"
}

# data "aws_ecr_repository" "repo_for_projects" {
#   name = "repo-for-projects"
# }




