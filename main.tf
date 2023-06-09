# --- S3 ----------------------------------------------------------------------
data "aws_caller_identity" "current" {}

resource "random_uuid" "bucket_suffix" {
  keepers = {
    name = local.kebab_case_name
  }
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    actions = [
      "s3:GetObject"
    ]

    resources = [
      "arn:aws:s3:::${local.bucket_name}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.cf.id}"]
    }

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = local.bucket_name
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}

# --- CloudFront --------------------------------------------------------------
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${local.upper_camel_case_name}OAC"
  description                       = "${var.name} OAC"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "cf" {
  comment = "${var.name} CloudFront Distribution"
  origin {
    domain_name              = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    origin_id                = "${local.upper_camel_case_name}Origin"
  }

  aliases = local.domain_aliases

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    target_origin_id       = "${local.upper_camel_case_name}Origin"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  custom_error_response {
    error_caching_min_ttl = 1
    error_code            = "403"
    response_code         = "200"
    response_page_path    = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = module.cert.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

# --- DNS ---------------------------------------------------------------------
resource "aws_route53_record" "a" {
  for_each = toset(local.domain_aliases)

  zone_id = var.route53_zone_id
  name    = each.key
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cf.domain_name
    zone_id                = aws_cloudfront_distribution.cf.hosted_zone_id
    evaluate_target_health = false
  }
}

# --- SSL ---------------------------------------------------------------------
module "cert" {
  source = "terraform-aws-modules/acm/aws"

  providers = {
    aws = aws.east
  }

  domain_name = var.fqdn
  zone_id     = var.route53_zone_id

  subject_alternative_names = var.subject_alternative_names

  wait_for_validation = true
}
