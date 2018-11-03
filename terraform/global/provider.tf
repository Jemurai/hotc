provider "aws" {
  region = "us-east-2"
}

terraform {
  backend "s3" {
    bucket = "example-tfstate"
    key    = "global/terraform.tfstate"
    region = "us-east-2"
  }
}
