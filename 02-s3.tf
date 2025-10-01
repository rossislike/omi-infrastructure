resource "random_string" "bucket_suffix" {
  length  = 4
  special = false
  upper   = false
}

locals {
  suffix = random_string.bucket_suffix.result
}

# resource "aws_s3_bucket" "website" {
#   bucket = "${var.project_name}-website-${local.suffix}-${var.environment}"
#   tags   = var.tags
# }


resource "aws_s3_bucket" "artifacts" {
  bucket = "${var.project_name}-artifacts-${local.suffix}-${var.environment}"
  tags   = var.tags
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}