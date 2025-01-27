terraform {
  required_providers {
    okta = {
      source  = "okta/okta"
      version = "~> 4.12.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "okta" {
  org_name  = var.org_name
  base_url  = var.base_url
  api_token = var.api_token
}