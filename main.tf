


### AWS S3 Bucket endpoint with website files & route 53, cloudfront, and WAF



# Configure the AWS provider
provider "aws" {
  region = "us-east-1"
}



######################################
### Begin S3 Website Configuration ###
######################################

### Create an S3 bucket and website endpoint


# create the website bucket
resource "aws_s3_bucket" "the-bucket" {
  bucket = "www.mywebsite.com" # INPUT YOUR BUCKET NAME HERE
  force_destroy = true # allows forced destruction of the bucket and its contents if you perform "terraform destroy"
}

# enable the bucket as a website endpoint and uploads your web files to S3
resource "aws_s3_bucket_website_configuration" "s3-bucket" {
  bucket = aws_s3_bucket.the-bucket.id

  index_document { # list html main document
    suffix = "index.html"
  }
  error_document { # list html error document
    key = "error.html"
  }

  # run local-exec
  provisioner "local-exec" {
    command = "aws s3 cp ./webfiles/ s3://${aws_s3_bucket_website_configuration.s3-bucket.bucket}/ --recursive" # use local-exec to execute file upload to s3
  }
}

# Allow cloudfront access to bucket
resource "aws_s3_bucket_policy" "logs-bucket-policy" {
  bucket = aws_s3_bucket.logs-bucket.id # references previously created bucket

  policy = jsonencode({ 
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "put-s3-logs",
            "Action": [
                "s3:DeleteObject",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:PutObject"
            ],
            "Effect": "Allow",
            "Resource": [aws_cloudfront_distribution.s3_distribution.arn] # references cloudfront dist created below
        },
      ]
    }
  )
}

# You can also create a policy directly within the bucket, as opposed to what's done here. Each has their uses.
# create bucket policy for public-read access
resource "aws_s3_bucket_policy" "s3-bucket-policy" {
  bucket = aws_s3_bucket_website_configuration.s3-bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          aws_s3_bucket.the-bucket.arn,
          "${aws_s3_bucket.the-bucket.arn}/*",
        ]
      },
    ]
  })
}
#####################################################################################


############################################
### Create route53 hosted zone & records ###
############################################

# Create a Route 53 Hosted Zone
resource "aws_route53_zone" "r53-zone" {
  name = aws_s3_bucket.the-bucket.id
}

# R53 A record to cloudfront distribution
resource "aws_route53_record" "www4" {
  zone_id = aws_route53_zone.r53-zone.zone_id
  name    = aws_s3_bucket.the-bucket.id
  type    = "A"

    alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name # CF distribution domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id # CF distribution hosted_zone_id
    evaluate_target_health = true
  }
}

# R53 AAAA record to cloudfront distribution
resource "aws_route53_record" "www6" {
  zone_id = aws_route53_zone.r53-zone.zone_id
  name    = aws_s3_bucket.the-bucket.id
  type    = "AAAA"

    alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name # CF distribution domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id # CF distribution hosted_zone_id
    evaluate_target_health = true
  }
}

# R53 CNAME to add sub-domain www points to A record already established
resource "aws_route53_record" "cname4" {
  zone_id = aws_route53_zone.r53-zone.zone_id
  name    = "www.${aws_s3_bucket.the-bucket.id}"
  type    = "CNAME"

  records = [aws_route53_record.www4.name]
  ttl     = "300"
}

# R53 CNAME to add sub-domain www points to AAAA record already established
resource "aws_route53_record" "cname6" {
  zone_id = aws_route53_zone.r53-zone.zone_id
  name    = "www.${aws_s3_bucket.the-bucket.id}"
  type    = "CNAME"

  records = [aws_route53_record.www6.name]
  ttl     = "300"
}
#####################################################################################


# Private cert is commented out for testing, or if you're not going to use one. This code
# will wait for the certificate to be created before continuing so it may take a while.
# If you create a private certificate for a domain you've purchased, you'll want to go to the end
# of the cloudfront resource and comment out the default cert, uncomment and input the name
# of your own cert in the config field

######################################
### create ACM private certificate ###
######################################
/* 
resource "aws_acm_certificate" "terra-cert" {
  domain_name       = aws_s3_bucket.the-bucket.id
  validation_method = "DNS"
  subject_alternative_names = ["www.${aws_s3_bucket.the-bucket.id}"]

  tags = {
    Environment = "test"
  }

  lifecycle {
    create_before_destroy = true
  }
}


data "aws_route53_zone" "r53-zone-data" {
  private_zone = false
  zone_id      = aws_route53_zone.r53-zone.zone_id
}


resource "aws_route53_record" "acm-record" {
  for_each = {
    for dvo in aws_acm_certificate.terra-cert.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = dvo.domain_name == "${aws_s3_bucket.the-bucket.id}" ? data.aws_route53_zone.r53-zone-data.zone_id : data.aws_route53_zone.r53-zone-data.zone_id
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

resource "aws_acm_certificate_validation" "acm-val" {
  certificate_arn         = aws_acm_certificate.terra-cert.arn
  validation_record_fqdns = [for record in aws_route53_record.acm-record : record.fqdn]
}
#####################################################################################
*/





####################
### Create a WAF ###
####################

# Create a geographic set for the WAF ACL
resource "aws_waf_geo_match_set" "geo-set-acl" {
  name = "geo-set-acl"

  geo_match_constraint {
    type  = "Country"
    value = "US"
  }

  geo_match_constraint {
    type  = "Country"
    value = "CA"
  }
}

# Create the WAF rule - this rule focuses on blocking/allowing everything BUT the constraints within geo-set-acl
resource "aws_waf_rule" "wafrule" {
  depends_on  = [aws_waf_geo_match_set.geo-set-acl]
  name        = "tfWAFRule"
  metric_name = "tfWAFRule"

  predicates {
    data_id = aws_waf_geo_match_set.geo-set-acl.id
    negated = true # focuses on blocking/allowing {blocking here} everything BUT the geo-set-acl constraints
    type    = "GeoMatch"
  }
}

# Create the WAF ACL
resource "aws_waf_web_acl" "cf-waf" {
  depends_on = [
    aws_waf_geo_match_set.geo-set-acl,
    aws_waf_rule.wafrule,
  ]

  name        = "tfWebACL"
  metric_name = "tfWebACL"

  default_action {
    type = "ALLOW"
  }

  rules {
    action {
      type = "BLOCK"
    }

    priority = 1
    rule_id  = aws_waf_rule.wafrule.id
    type     = "REGULAR"
  }
}
#####################################################################################


#######################################
### Cloudfront Distribution Section ###
#######################################

# create origin id for cloudfront
locals {
  s3_origin_id = "myS3Origin"
}

# Create cloudfront distribution Origin Access Control
resource "aws_cloudfront_origin_access_control" "OAC" {
  name                              = "mywebsite-terraform-OAC" # NAME YOUR CLOUDFRONT ORIGIN
  description                       = "OAC Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Create cloudfront distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  web_acl_id = aws_waf_web_acl.cf-waf.id # Sets previously created WAF as CF firewall

  origin {
    domain_name              = aws_s3_bucket.the-bucket.bucket_regional_domain_name # use the domain name of the website bucket
    origin_access_control_id = aws_cloudfront_origin_access_control.OAC.id # use id of previously created OAC
    origin_id                = local.s3_origin_id # origin id previously created for bucket
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CF Distro"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA"]
    }
  }

  tags = {
    Environment = "production"
    Terraform = "True"
  }
  
  # SSL certificate
  viewer_certificate {
    /* acm_certificate_arn = aws_acm_certificate.terra-cert.arn # use previously created ACM private cert */
    cloudfront_default_certificate = true # use a default cloudfront certificate
    ssl_support_method  = "sni-only"
  }
}
#####################################################################################
