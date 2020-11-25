# public zone
data "aws_route53_zone" "mkaito_net" {
  name         = "mkaito.net."
}
