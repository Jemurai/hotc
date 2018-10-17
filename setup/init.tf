provider "aws" {
    region = "${var.region}"
}

resource "aws_s3_bucket" "abedra-tfstate" {
  bucket = "${var.state-bucket}"
  acl = "private"
  versioning {
      enabled = true
  }
}

terraform {
    backend "s3" {
        bucket = "abedra-tfstate"
        key = "setup/terraform.tfstate"
        region = "us-east-2"
    }
}