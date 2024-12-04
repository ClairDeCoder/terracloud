# WAF Geo Match Set
# https://docs.aws.amazon.com/waf/latest/developerguide/waf-rule-statement-type-geo-match.html
#
resource "aws_waf_geo_match_set" "geo_set" {
  name = "${var.environment}-geo-set"

  geo_match_constraint {
    type  = "Country"
    value = "US"
  }

  geo_match_constraint {
    type  = "Country"
    value = "CA"
  }
}

# WAF Rule
# https://docs.aws.amazon.com/waf/latest/developerguide/waf-rules.html
#
resource "aws_waf_rule" "geo_block_rule" {
  name        = "${var.environment}-geo-block-rule"
  metric_name = "GeoBlockRule"

  predicates {
    data_id = aws_waf_geo_match_set.geo_set.id
    negated = true
    type    = "GeoMatch"
  }
}

# WAF Web ACL
# https://docs.aws.amazon.com/waf/latest/developerguide/web-acl.html
#
resource "aws_waf_web_acl" "web_acl" {
  name        = "${var.environment}-web-acl"
  metric_name = "WebACLMetric"

  default_action {
    type = "ALLOW"
  }

  rules {
    action {
      type = "BLOCK"
    }
    priority = 1
    rule_id  = aws_waf_rule.geo_block_rule.id
    type     = "REGULAR"
  }

  tags = {
    Environment = var.environment
  }
}
