resource "random_string" "bucket_suffix" {
  length  = 4
  special = false
  upper   = false
}

locals {
  suffix = random_string.bucket_suffix.result
}

resource "aws_s3_bucket" "website" {
  bucket = "${var.project_name}-website-${var.environment}"
  tags   = var.tags
}

resource "aws_s3_bucket_cors_configuration" "website" { 
  bucket = aws_s3_bucket.website.id

  cors_rule { 
    allowed_methods = ["GET"]
    allowed_origins = [
      "http://localhost:5173",
      "https://${lookup(var.env_domain, var.environment)}"
    ]
  }
}

resource "aws_s3_bucket" "artifacts" {
  bucket        = "${var.project_name}-artifacts-${var.environment}"
  tags          = var.tags
  force_destroy = true
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${var.project_name}-lambda-${var.environment}"
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}