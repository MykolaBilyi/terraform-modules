locals {
  test_volume = "test-volume"
}

module "backup" {
  source = "./docker_volumes_backup"

  connection = module.connection

  backup_config = {
    "type"            = "sftp"
    "host"            = var.BACKUP_HOST
    "user"            = var.BACKUP_USER
    "key_file"        = "$${RCLONE_CONFIG_DIR}/id_rsa"
    "shell_type"      = "unix"
    "md5sum_command"  = "none"
    "sha1sum_command" = "none"
  }

  secrets = {
    "id_rsa" = file("~/.ssh/id_rsa")
  }

  backup_label = "test.backup"
}

resource "ssh_resource" "volume_restore_test" {
  host  = module.connection.host
  user  = module.connection.user
  agent = module.connection.agent

  when = "destroy"

  commands = [
    "docker volume rm ${local.test_volume} || true",
  ]
}

# resource "ssh_resource" "volume_test" {
#   host        = module.connection.host
#   user        = module.connection.user
#   agent       = module.connection.agent

#   when = "create"

#   commands = [
#     "docker volume create --label test.backup= mykola",
#     "docker volume create --label test.backup= ${local.test_volume}",
#     "echo '{\"test\":\"passed\"}' > /var/lib/docker/volumes/${local.test_volume}/_data/test.json",
#   ]
# }

check "volume_content" {
  data "external" "volume_content" {
    program = ["ssh", "-o", "StrictHostKeyChecking=no", "-p", module.connection.port, "${module.connection.user}@${module.connection.host}", "docker", "run", "--rm", "-t", "-v", "${local.test_volume}:/test", "alpine", "cat", "/test/test.json"]
  }

  assert {
    condition     = data.external.volume_content.result.test == "passed"
    error_message = "Unexpected volume content"
  }
}

variable "BACKUP_HOST" {
  type = string
}

variable "BACKUP_USER" {
  type = string
}
