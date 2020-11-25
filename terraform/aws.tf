provider  "aws" {
  version = "~> 2.15"
  region = "eu-west-2"
  profile = "mkaito"
}

terraform {
  backend "s3" {
    bucket = "mkaito-tfstate"
    dynamodb_table = "mkaito-tfstate-lock"
    encrypt = true
    key    = "mkaito/terraform.tfstate"
    region = "eu-west-2"
    profile = "mkaito"
  }
  ## Prevent unwanted updates
  required_version = "~> 0.12.29" # Use nix-shell or nix develop
}
