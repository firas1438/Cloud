provider "aws" {
  region = var.region
  # access_key = ""
  # secret_key = ""
  # token      = ""
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
