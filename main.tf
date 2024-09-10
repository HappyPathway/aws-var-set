locals {
  aws_secrets = [
    "AWS_ACCESS_KEY_ID",
    "AWS_SECRET_ACCESS_KEY",
  ]
}

resource null_resource secrets {
  for_each = toset(local.aws_secrets)
  provisioner "local-exec" {
    command = "env | grep ${each.value}"
  }
}
