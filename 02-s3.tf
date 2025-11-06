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


resource "aws_s3_bucket" "artifacts" {
  bucket        = "${var.project_name}-artifacts-${var.environment}"
  tags          = var.tags
  force_destroy = true
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${var.project_name}-lambda-${var.environment}"
  tags   = var.tags
}

resource "aws_s3_bucket" "photos_bucket" {
  bucket = "${var.project_name}-photos-${var.environment}"
  tags   = var.tags
  
}

resource "aws_s3_bucket_public_access_block" "photos" {
  bucket = aws_s3_bucket.photos_bucket.id
  
  block_public_acls       = false
  block_public_policy     = false 
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "photos_bucket_policy" {
  bucket = aws_s3_bucket.photos_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.photos_bucket.arn}/*"
      }
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.photos]
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}