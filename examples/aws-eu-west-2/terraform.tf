# Example environment for the templates in templates/ to route work against — not a
# live environment. Backend is local on purpose so cloning this repo never points at
# real state. Swap for a remote backend (S3, Azure, GCS, ...) before using this as the
# starting point for an actual environment.
terraform {
  required_version = "~> 1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = var.aws_region
}
