resource "aws_apigatewayv2_api" "api" {
  name          = "${var.project_name}-api-${var.environment}"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = [
      "http://localhost:5173",
      "https://${aws_cloudfront_distribution.distribution.domain_name}",

    ]
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers = ["Content-Type", "Authorization"]
  }
}

# resource "aws_apigatewayv2_authorizer" "photo_gallery" {  
#   api_id          = aws_apigatewayv2_api.api.id
#   name            = "Cognito-PhotoGallery"
#   authorizer_type = "JWT"
#   jwt_configuration {
#     issuer   = "https://cognito-idp.us-east-1.amazonaws.com/${aws_cognito_user_pool.pool.id}"
#     audience = ["${aws_cognito_user_pool_client.client.id}"]
#   }
#   identity_sources = ["$request.header.Authorization"]
# }


resource "aws_apigatewayv2_stage" "stage" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
}

####################################################
resource "aws_apigatewayv2_integration" "test_lambda" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_uri        = aws_lambda_function.test_lambda.arn
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
}

resource "aws_apigatewayv2_route" "test_lambda" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /test"
  target    = "integrations/${aws_apigatewayv2_integration.test_lambda.id}"

  # authorizer_id = aws_apigatewayv2_authorizer.photo_gallery.id
  # authorization_type = "JWT"
}

####################################################
# resource "aws_apigatewayv2_integration" "get_photo" {
#   api_id                 = aws_apigatewayv2_api.api.id
#   integration_uri        = aws_lambda_function.get_photo.arn
#   integration_type       = "AWS_PROXY"
#   integration_method     = "POST"
# }

# resource "aws_apigatewayv2_route" "get_photo" {
#   api_id    = aws_apigatewayv2_api.api.id
#   route_key = "GET /photo"
#   target    = "integrations/${aws_apigatewayv2_integration.get_photo.id}"

#   authorizer_id = aws_apigatewayv2_authorizer.photo_gallery.id
#   authorization_type = "JWT"
# }

####################################################
# resource "aws_apigatewayv2_integration" "post_photo" {
#   api_id                 = aws_apigatewayv2_api.api.id
#   integration_uri        = aws_lambda_function.post_photo.arn
#   integration_type       = "AWS_PROXY"
#   integration_method     = "POST"
# }

# resource "aws_apigatewayv2_route" "post_photo" {
#   api_id    = aws_apigatewayv2_api.api.id
#   route_key = "POST /photos"
#   target    = "integrations/${aws_apigatewayv2_integration.post_photo.id}"

#   authorizer_id = aws_apigatewayv2_authorizer.photo_gallery.id
#   authorization_type = "JWT"
# }

####################################################

# resource "aws_apigatewayv2_integration" "upload_photo" {
#   api_id                 = aws_apigatewayv2_api.api.id
#   integration_uri        = aws_lambda_function.upload_photo.arn
#   integration_type       = "AWS_PROXY"
#   integration_method     = "POST"
# }

# resource "aws_apigatewayv2_route" "upload_photo" {
#   api_id    = aws_apigatewayv2_api.api.id
#   route_key = "POST /upload"
#   target    = "integrations/${aws_apigatewayv2_integration.upload_photo.id}"

#   authorizer_id = aws_apigatewayv2_authorizer.photo_gallery.id
#   authorization_type = "JWT"
# }