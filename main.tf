locals {
  aws_secrets = [
    "AWS_ACCESS_KEY_ID",
    "AWS_SECRET_ACCESS_KEY",
  ]
  gcp_secrets = [
  ]
  all_secrets = toset(concat(local.aws_secrets, local.gcp_secrets))
}

provider "github" {
  owner = "HappyPathway"
}

resource null_resource secrets {
  triggers = {
    timestamp = timestamp()
  }
  for_each = toset(local.all_secrets)
  provisioner "local-exec" {
    command = "env | grep ${each.value} | awk -F= '{ print $NF }' > ${each.value}"
  }
}

data local_file secrets {
  for_each = toset(local.all_secrets)
  filename = each.value
  depends_on = [
    null_resource.secrets
  ]
}

locals {
  secrets = { for secret in local.all_secrets : secret => chomp(lookup(data.local_file.secrets, secret).content) }
}

resource "github_actions_organization_secret" "secrets" {
  for_each = toset([
    "AWS_SECRET_ACCESS_KEY"
  ])
  secret_name     = each.value
  visibility      = "all"
  plaintext_value = lookup(local.secrets, each.value)
}

moved {
  from = github_actions_organization_variable.example_variable
  to = github_actions_organization_variable.variables
}

resource "github_actions_organization_variable" "variables" {
  for_each = toset([
    "AWS_ACCESS_KEY_ID"
  ])
  variable_name   = each.value
  visibility      = "all"
  value           = lookup(local.secrets, each.value)
}

output aws_credentials {
  value = {
    for secret in ["AWS_SECRET_ACCESS_KEY", "AWS_ACCESS_KEY_ID"] : secret => lookup(local.secrets, secret)
  }
}
