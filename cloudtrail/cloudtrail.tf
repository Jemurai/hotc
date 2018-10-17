provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "abedra-tfstate"
    key    = "cloudtrail/terraform.tfstate"
    region = "us-east-2"
  }
}

data "aws_iam_policy_document" "policy" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = ["${aws_s3_bucket.abedra-audit.arn}"]
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.abedra-audit.arn}/audit/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_s3_bucket_policy" "audit" {
  bucket = "${aws_s3_bucket.abedra-audit.bucket}"
  policy = "${data.aws_iam_policy_document.policy.json}"
}

resource "aws_s3_bucket" "abedra-audit" {
  bucket = "${var.cloudtrail-bucket}"
  acl    = "private"
}

resource "aws_cloudtrail" "audit" {
  name                          = "${var.cloudtrail-name}"
  s3_bucket_name                = "${aws_s3_bucket.abedra-audit.id}"
  s3_key_prefix                 = "${var.s3-prefix}"
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  depends_on                    = ["aws_s3_bucket_policy.audit"]
}