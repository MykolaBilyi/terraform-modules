# Provision user

Module to provision user on a remote host.

## Usage example

```hcl
module "admin_user" {
  source = "github.com/MykolaBilyi/terraform-modules//provision_user?ref=v0.3"

  user_name   = "testuser"
  public_keys = [file("~/.ssh/id_rsa.pub")]

  connection = {
    type        = "ssh"
    user        = "root"
    private_key = file("~/.ssh/id_rsa")
    host        = "my.domain.com"
  }
}

check "response" {
  data "external" "ssh" {
    program = ["ssh", "testuser@my.domain.com", "echo", "\"{\\\"user_id\\\":\\\"$(id -u)\\\"}\""]
  }

  assert {
    condition     = data.external.ssh.result["user_id"] == module.admin_user.user_id
    error_message = "Response is ${jsonencode(data.external.ssh.result)}"
  }
}
```
