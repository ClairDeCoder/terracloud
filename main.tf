provider "aws" {
  region = var.region
}

# S3 Module
module "s3" {
  source      = "./modules/s3"
  bucket_name = var.bucket_name
  environment = var.environment
}

# Route 53 Module
module "route53" {
  source       = "./modules/route53"
  domain_name  = var.domain_name
  cf_domain    = module.cloudfront.cf_domain_name
}

# WAF Module
module "waf" {
  source      = "./modules/waf"
  environment = var.environment
}

# CloudFront Module
module "cloudfront" {
  source        = "./modules/cloudfront"
  bucket_domain = module.s3.bucket_domain_name
  web_acl_id    = module.waf.web_acl_id
  environment   = var.environment
}
