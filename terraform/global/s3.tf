data "aws_iam_policy_document" "cloudtrail" {
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
    resources = ["${aws_s3_bucket.example-audit.arn}/audit/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = "${aws_s3_bucket.example-audit.bucket}"
  policy = "${data.aws_iam_policy_document.cloudtrail.json}"
}

resource "aws_s3_bucket" "example-audit" {
  bucket = "example-audit"
  acl    = "private"
}

resource "aws_s3_bucket" "example-tfstate" {
  bucket = "example-tfstate"
  acl = "private"

  versioning {
      enabled = true
  }
}
