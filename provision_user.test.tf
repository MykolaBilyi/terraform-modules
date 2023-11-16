data "external" "current_user" {
  program = ["bash", "${path.module}/test-json-helper.sh", "id", "-un"]
}

module "admin_user" {
  source = "./provision_user"

  connection = module.connection

  user_name = data.external.current_user.result.output
  groups    = ["sudo", "docker"]
}

module "user_keys" {
  source = "github.com/MykolaBilyi/public-keys?ref=v0.2"

  connection = module.connection
}

check "user_access" {
  data "external" "user_id" {
    program = ["ssh", "-o", "StrictHostKeyChecking=no", "-p", module.connection.port, "${data.external.current_user.result.output}@${module.connection.host}", "echo", "\"{\\\"user_id\\\":\\\"$(id -u)\\\"}\""]
  }

  assert {
    condition     = data.external.user_id.result.user_id == module.admin_user.user_id
    error_message = "Error create/access user"
  }
}

check "user_groups" {
  data "external" "user_groups" {
    program = ["ssh", "-o", "StrictHostKeyChecking=no", "-p", module.connection.port, "${data.external.current_user.result.output}@${module.connection.host}", "echo", "\"{\\\"groups\\\":\\\"$(id -nG)\\\"}\""]
  }

  assert {
    condition     = data.external.user_groups.result.groups == "${data.external.current_user.result.output} docker"
    error_message = "Wrong user groups"
  }
}

check "user_sudo" {
  data "external" "root_id" {
    program = ["ssh", "-o", "StrictHostKeyChecking=no", "-p", module.connection.port, "${data.external.current_user.result.output}@${module.connection.host}", "echo", "\"{\\\"user_id\\\":\\\"$(sudo id -u)\\\"}\""]
  }

  assert {
    condition     = data.external.root_id.result.user_id == "0"
    error_message = "No access to sudo"
  }
}
