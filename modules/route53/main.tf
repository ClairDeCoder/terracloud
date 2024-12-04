
# Choose R53 hosted zone
# https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-working-with.html
#
resource "aws_route53_zone" "r53_zone" {
  name = var.domain_name
}

# Target A Records
# https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/rrsets-working-with.html
#
resource "aws_route53_record" "cf_alias" {
  zone_id = aws_route53_zone.r53_zone.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.cf_domain
    zone_id                = var.cf_zone_id
    evaluate_target_health = false
  }
}
