resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.project_name}-lambda-policy-${var.environment}"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.website.arn,
          "${aws_s3_bucket.website.arn}/*"
        ]

      },
      #   {
      #     Effect = "Allow"
      #     Action = [
      #       "dynamodb:GetItem",
      #       "dynamodb:PutItem",
      #       "dynamodb:UpdateItem",
      #       "dynamodb:DeleteItem",
      #       "dynamodb:Query",
      #       "dynamodb:Scan"
      #     ]
      #     Resource = [aws_dynamodb_table.table.arn]
      #   }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.project_name}-${var.environment}"
  retention_in_days = 14
}

resource "aws_lambda_layer_version" "python_layer" {
  filename            = "layer/layer.zip"
  layer_name          = "${var.project_name}-layer-${var.environment}"
  description         = "Python dependencies layer"
  compatible_runtimes = ["python3.13"]
}

####################################################
resource "aws_lambda_function" "test_lambda" {
  filename         = "lambdas/test_lambda.zip"
  function_name    = "${var.project_name}-test-lambda-${var.environment}"
  source_code_hash = filebase64sha256("lambdas/test_lambda.zip")
  role             = aws_iam_role.lambda_role.arn
  handler          = "test_lambda.lambda_handler"
  runtime          = "python3.13"
  layers           = [aws_lambda_layer_version.python_layer.arn]

  logging_config {
    log_group  = aws_cloudwatch_log_group.lambda_logs.name
    log_format = "Text"
  }
  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.website.bucket
      #   PHOTOS_TABLE_NAME = aws_dynamodb_table.photogallery.name
    }
  }
}

# resource "aws_lambda_permission" "allow_test_lambda" {
#     statement_id  = "AllowAPIGatewayInvokeGetPhotos"
#     action        = "lambda:InvokeFunction"
#     function_name = aws_lambda_function.test_lambda.function_name
#     principal     = "apigateway.amazonaws.com"
#     source_arn    = "${aws_apigatewayv2_api.photo_gallery.execution_arn}/*/*"
# }