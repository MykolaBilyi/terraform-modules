data "external" "current_user" {
  program = ["bash", "${path.module}/test-json-helper.sh", "id", "-un"]
}

data "external" "current_ip" {
  program = ["bash", "${path.module}/test-json-helper.sh", "curl", "-s", "ifconfig.co"]
}

locals {
  user = data.external.current_user.result.output # Shorthand
  ip   = data.external.current_ip.result.output   # Shorthand
}

module "admin_user" {
  source = "./provision_user"

  connection = module.connection

  user_name  = local.user
  groups     = ["sudo", "docker"]
  on_destroy = "keep"
}

module "user_keys" {
  source = "github.com/MykolaBilyi/public-keys?ref=v0.2"

  connection = module.connection
}

resource "tls_private_key" "restricted_user_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "random_pet" "restricted_user" {
}

module "restricted_user" {
  source = "./provision_user"

  connection = module.connection

  user_name        = random_pet.restricted_user.id
  public_keys      = [tls_private_key.restricted_user_key.public_key_openssh]
  command          = "echo '{\"test\":\"passed\"}'"
  from             = ["${local.ip}/32"]
  port-forwarding  = false
  x11-forwarding   = false
  agent-forwarding = false
  pty              = false
}

check "user_access" {
  data "external" "user_id" {
    program = ["ssh", "-o", "StrictHostKeyChecking=no", "-p", module.connection.port, "${local.user}@${module.connection.host}", "echo \"{\\\"user_id\\\":\\\"$(id -u)\\\"}\""]
  }

  assert {
    condition     = data.external.user_id.result.user_id == module.admin_user.user_id
    error_message = "User access error"
  }
}

check "user_groups" {
  data "external" "user_groups" {
    program = ["ssh", "-o", "StrictHostKeyChecking=no", "-p", module.connection.port, "${local.user}@${module.connection.host}", "echo \"{\\\"groups\\\":\\\"$(id -nG)\\\"}\""]
  }

  assert {
    condition     = data.external.user_groups.result.groups == "${local.user} docker"
    error_message = "Wrong user groups"
  }
}

check "user_sudo" {
  data "external" "root_id" {
    program = ["ssh", "-o", "StrictHostKeyChecking=no", "-p", module.connection.port, "${local.user}@${module.connection.host}", "echo \"{\\\"user_id\\\":\\\"$(sudo id -u)\\\"}\""]
  }

  assert {
    condition     = data.external.root_id.result.user_id == "0"
    error_message = "No access to sudo"
  }
}

check "restricted_user_access" {
  data "external" "restricted_user_access" {
    program = ["ssh-agent", "bash", "-c", <<EOF
      echo '${tls_private_key.restricted_user_key.private_key_openssh}' | ssh-add -q -
      ssh -o StrictHostKeyChecking=no -p ${module.connection.port} ${module.restricted_user.user_name}@${module.connection.host} echo '{\"test\":\"failed\"}'
    EOF
    ]
  }

  assert {
    condition     = data.external.restricted_user_access.result.test == "passed"
    error_message = "Restricted user access error"
  }
}
