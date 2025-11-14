resource "aws_iam_role" "codebuild" {
  name = "${var.project_name}-codebuild-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

data "aws_codestarconnections_connection" "github" {
  arn = "arn:aws:codeconnections:us-east-1:585768164578:connection/9d85580f-8ddc-44c8-8ddf-755c851c2b96"
}

# IAM Policy for CodeBuild
resource "aws_iam_role_policy" "codebuild" {
  role = aws_iam_role.codebuild.name
  name = "${var.project_name}-codebuild-policy-${var.environment}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = [
          "arn:aws:s3:::${var.project_name}*",
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "cloudfront:CreateInvalidation"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "codestar-connections:UseConnection",
          "codestar-connections:GetConnection",
          "codestar-connections:GetConnectionToken"
        ]
        Resource = [
          data.aws_codestarconnections_connection.github.arn
        ]
      }
    ]
  })
}

resource "aws_codebuild_project" "github" {
  name         = "${var.project_name}-codebuild-${var.environment}"
  description  = "${var.project_name}-codebuild-${var.environment}"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }


  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "S3_BUCKET"
      value = aws_s3_bucket.website.bucket
    }

    environment_variable {
      name  = "CLOUDFRONT_DISTRIBUTION_ID"
      value = aws_cloudfront_distribution.distribution.id
    }

    environment_variable {
      name  = "VITE_API_URL"
      value = "${aws_apigatewayv2_api.api.api_endpoint}${var.environment == "prod" ? "" : "/${var.environment}"}"
    }
  }

  source {
    type     = "GITHUB"
    location = "https://github.com/${var.github_owner}/${var.github_repo}.git"
    auth {
      type     = "CODECONNECTIONS"
      resource = data.aws_codestarconnections_connection.github.arn
    }
  }

  source_version = var.environment
}

# resource "aws_codebuild_webhook" "webhook" {
#   project_name = aws_codebuild_project.github.name
#   build_type   = "BUILD"
#   filter_group {
#     filter {
#       type    = "EVENT"
#       pattern = "PULL_REQUEST_MERGED"
#     }
#   }
# }