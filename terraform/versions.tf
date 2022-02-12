terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    dns = {
      source = "hashicorp/dns"
    }
  }

}
