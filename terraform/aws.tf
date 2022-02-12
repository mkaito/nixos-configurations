provider "aws" {
  region  = "eu-west-2"
  profile = "mkaito"
}

terraform {
  backend "s3" {
    bucket         = "mkaito-tfstate"
    dynamodb_table = "mkaito-tfstate-lock"
    encrypt        = true
    key            = "mkaito/terraform.tfstate"
    region         = "eu-west-2"
    profile        = "mkaito"
  }
}
