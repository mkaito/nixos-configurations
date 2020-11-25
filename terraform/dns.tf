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
