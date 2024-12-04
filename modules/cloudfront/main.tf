
# Cloudfront Distro Setup
# https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Introduction.html
#
resource "aws_cloudfront_distribution" "cf_distribution" {
  origin {
    domain_name = var.bucket_domain
    origin_id   = "S3Origin"

    origin_access_control_id = aws_cloudfront_origin_access_control.OAC.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront Distribution for S3 Website"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3Origin"

    viewer_protocol_policy = "redirect-to-https"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  web_acl_id = var.web_acl_id
}

# Origin Access Control
# https://aws.amazon.com/blogs/networking-and-content-delivery/amazon-cloudfront-introduces-origin-access-control-oac/
#
resource "aws_cloudfront_origin_access_control" "OAC" {
  name                              = "S3OriginAccessControl"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
