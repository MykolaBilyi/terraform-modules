# Docker Volumes Backup module

This module is used to backup docker volumes on a remote host accessibale via SSH.

## Usage example

```hcl
module "backup" {
  source = "github.com/MykolaBilyi/terraform-modules//docker_volumes_backup?ref=v0.9"

  connection = {
    user        = "root"
    private_key = file("~/.ssh/id_rsa")
    host        = "my.domain.com"
  }

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

  backup_label = "example.backup"
}
```
