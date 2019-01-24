provider "aws" {
  region = "${var.aws_region}"
}

terraform {
  // bucket = "<s3_bucket_prefix>tfstate"
  backend "s3" {
    key    = "global/terraform.tfstate"
    region = "us-east-2"
  }
}
