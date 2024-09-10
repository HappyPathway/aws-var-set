locals {
  aws_secrets = [
    "AWS_ACCESS_KEY_ID",
    "AWS_SECRET_ACCESS_KEY",
  ]
}

resource null_resource secrets {
  triggers = {
    timestamp = timestamp()
  }
  for_each = toset(local.aws_secrets)
  provisioner "local-exec" {
    command = "env | grep ${each.value} | awk -F= '{ print $NF }' > ${each.value}"
  }
}

data local_file secrets {
  for_each = toset(local.aws_secrets)
  filename = each.value
  depends_on = [
    null_resource.secrets
  ]
}

locals {
  secrets = { for secret in local.aws_secrets : secret => chomp(lookup(data.local_file.secrets, secret).content) }
}

resource "github_actions_organization_secret" "secrets" {
  for_each = tomap(local.secrets)
  secret_name     = each.key
  visibility      = "all"
  plaintext_value = each.value
}
