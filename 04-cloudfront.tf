resource "aws_cloudfront_origin_access_control" "origin_access_control" {
  name                              = "${var.project_name}-client-${var.environment}"
  description                       = "${var.project_name}-client-${var.environment}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  #   aliases             = ["${var.project_name}.rumothy.com"]

  origin {
    domain_name              = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.website.id
    origin_access_control_id = aws_cloudfront_origin_access_control.origin_access_control.id
    origin_path              = "/dist"
  }

  #   origin {
  #     domain_name = replace(aws_apigatewayv2_api.photo_gallery.api_endpoint, "https://", "")
  #     origin_id   = "api_gateway"
  #     custom_origin_config {
  #       http_port              = 80
  #       https_port             = 443
  #       origin_protocol_policy = "https-only"
  #       origin_ssl_protocols   = ["TLSv1.2"]
  #     }
  #   }


  default_cache_behavior {
    cached_methods   = ["GET", "HEAD"]
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    target_origin_id = aws_s3_bucket.website.id


    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    cache_policy_id = "b2884449-e4de-46a7-ac36-70bc7f1ddd6d"
  }

  #   ordered_cache_behavior {
  #     path_pattern           = "/photos*"
  #     target_origin_id       = "api_gateway"
  #     allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
  #     cached_methods         = ["GET", "HEAD"]
  #     min_ttl                = 0
  #     viewer_protocol_policy = "redirect-to-https"
  #     default_ttl            = 3600
  #     max_ttl                = 86400
  #     compress               = true


  #     cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
  #     origin_request_policy_id = "b689b0a8-53d0-40ab-baf2-68738e2966ac"
  #   }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
  #   viewer_certificate {
  #     cloudfront_default_certificate = true
  #     acm_certificate_arn            = "arn:aws:acm:us-east-1:442359104502:certificate/adc37346-87f7-44c4-b997-2bd4e3d264da"
  #     ssl_support_method             = "sni-only"
  #     minimum_protocol_version       = "TLSv1.2_2021"
  #   }

  tags = var.tags
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.website.arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.distribution.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.website.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}

# resource "aws_route53_record" "record" {
#   zone_id = "Z0699518N1Z35PGULTY2"
#   name    = "photogallery.rumothy.com"

#   type = "A"
#   alias {
#     name                   = aws_cloudfront_distribution.distribution.domain_name
#     zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
#     evaluate_target_health = true
#   }
# }