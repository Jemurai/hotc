variable "aws_region" {
  default = "us-east-2"
}

variable "bucket_name_prefix" {
  default     = "example-"
  description = "Prefix added to buckets to avoid global conflicts."
}
