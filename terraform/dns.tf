# public zone
data "aws_route53_zone" "mkaito_net" {
  name         = "mkaito.net."
}

# Fetch value of existing records as variables
data "dns_a_record_set" "stargazer" {
  host = "stargazer.mkaito.net"
}

data "dns_aaaa_record_set" "stargazer" {
  host = "stargazer.mkaito.net"
}

# Public VM IPs
resource "aws_route53_record" "vmx_stargazer_mkaito_net_ipv4" {
  for_each = toset( ["69", "70", "71", "72", "73", "74"])
  zone_id = data.aws_route53_zone.mkaito_net.zone_id
  name    = "vm${each.key}.stargazer.${data.aws_route53_zone.mkaito_net.name}"
  type    = "A"
  ttl     = "60"
  records = ["95.217.103.1${each.key}"]
}

resource "aws_route53_record" "vmx_stargazer_mkaito_net_ipv6" {
  for_each = toset( ["69", "70", "71", "72", "73", "74"])
  zone_id = data.aws_route53_zone.mkaito_net.zone_id
  name    = "vm${each.key}.stargazer.${data.aws_route53_zone.mkaito_net.name}"
  type    = "AAAA"
  ttl     = "60"
  records = ["2a01:4f9:4b:12e2::${each.key}"]
}
