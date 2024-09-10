locals {
  aws_secrets = [
    "AWS_ACCESS_KEY_ID",
    "AWS_SECRET_ACCESS_KEY",
  ]
}

module "var" {
  for_each = toset(local.aws_secrets)
  source   = "HappyPathway/var/env"
  env_var  = each.value
}

resource "github_actions_organization_secret" "org_secret" {
  for_each = tomap({
    for secret in local.aws_secrets : secret => module.var[secret].value
  })
  secret_name     = each.key
  visibility      = "private"
  plaintext_value = each.value
}
