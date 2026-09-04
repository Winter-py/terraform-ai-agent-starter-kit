terraform {
  backend "s3" {
    bucket  = "terraform-state-<account_id>"
    encrypt = true
    key     = "regions/eu-west-2/terraform.tfstate"
    region  = "eu-west-2"
  }
}
