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

# VM CNAME
resource "aws_route53_record" "space_engineers_cname" {
  zone_id = data.aws_route53_zone.mkaito_net.zone_id
  name    = "se.${data.aws_route53_zone.mkaito_net.name}"
  type    = "CNAME"
  ttl     = "60"
  records = ["vm71.stargazer.mkaito.net"]
}

# Matrix
resource "aws_route53_record" "matrix_stargazer_a" {
  zone_id = data.aws_route53_zone.mkaito_net.zone_id
  name    = "matrix.stargazer.${data.aws_route53_zone.mkaito_net.name}"
  type    = "A"
  ttl     = "60"
  records = data.dns_a_record_set.stargazer.addrs
}

resource "aws_route53_record" "matrix_stargazer_aaaa" {
  zone_id = data.aws_route53_zone.mkaito_net.zone_id
  name    = "matrix.stargazer.${data.aws_route53_zone.mkaito_net.name}"
  type    = "AAAA"
  ttl     = "60"
  records = data.dns_aaaa_record_set.stargazer.addrs
}

# matrix SRV
resource "aws_route53_record" "matrix_srv" {
  zone_id = data.aws_route53_zone.mkaito_net.zone_id
  name    = "_matrix._tcp.${data.aws_route53_zone.mkaito_net.name}"
  type    = "SRV"
  ttl     = "60"
  records = ["0 0 443 matrix.stargazer.mkaito.net."]
}

# TURN
resource "aws_route53_record" "turn_a" {
  zone_id = data.aws_route53_zone.mkaito_net.zone_id
  name    = "turn.${data.aws_route53_zone.mkaito_net.name}"
  type    = "A"
  ttl     = "60"
  records = data.dns_a_record_set.stargazer.addrs
}

resource "aws_route53_record" "turn_aaaa" {
  zone_id = data.aws_route53_zone.mkaito_net.zone_id
  name    = "turn.${data.aws_route53_zone.mkaito_net.name}"
  type    = "AAAA"
  ttl     = "60"
  records = data.dns_aaaa_record_set.stargazer.addrs
}

# Prometheus & Grafana
resource "aws_route53_record" "prometheus_cname" {
  zone_id = data.aws_route53_zone.mkaito_net.zone_id
  name    = "prometheus.${data.aws_route53_zone.mkaito_net.name}"
  type    = "CNAME"
  ttl     = "60"
  records = ["stargazer.mkaito.net"]
}

resource "aws_route53_record" "grafana_cname" {
  zone_id = data.aws_route53_zone.mkaito_net.zone_id
  name    = "grafana.${data.aws_route53_zone.mkaito_net.name}"
  type    = "CNAME"
  ttl     = "60"
  records = ["stargazer.mkaito.net"]
}

resource "aws_route53_record" "alertmanager_cname" {
  zone_id = data.aws_route53_zone.mkaito_net.zone_id
  name    = "alertmanager.${data.aws_route53_zone.mkaito_net.name}"
  type    = "CNAME"
  ttl     = "60"
  records = ["stargazer.mkaito.net"]
}

# Odyssey delgated subdomain
resource "aws_route53_record" "jf_delegate" {
  zone_id = data.aws_route53_zone.mkaito_net.zone_id
  name    = "jf.${data.aws_route53_zone.mkaito_net.name}"
  type    = "NS"
  ttl     = "60"
  records = [
    "ns-1182.awsdns-19.org",
    "ns-1543.awsdns-00.co.uk",
    "ns-507.awsdns-63.com",
    "ns-917.awsdns-50.net",
  ]
}
