#Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "s3" {
    bucket         = "iti-final-task-s3-abdo"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "iti-final-task"
  }
}

