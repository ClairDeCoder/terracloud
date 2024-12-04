output "s3_bucket_domain" {
  value = module.s3.bucket_domain_name
}

output "cloudfront_domain" {
  value = module.cloudfront.cf_domain_name
}

output "route53_zone_id" {
  value = module.route53.zone_id
}
