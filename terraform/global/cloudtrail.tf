locals {
  cloudtrail_s3_prefix = "cloudtrail"
}

resource "aws_cloudtrail" "cloudtrail" {
  name                          = "cloudtrail"
  s3_bucket_name                = aws_s3_bucket.audit.id
  s3_key_prefix                 = local.cloudtrail_s3_prefix
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  depends_on                    = [aws_s3_bucket_policy.cloudtrail]
}

