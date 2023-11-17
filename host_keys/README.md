# Host keys

Module to read host keys from a remote host. It generates keys of given types if they are not present on the host, and returns them as a map.

## Usage example

```hcl
module "admin_user" {
  source = "github.com/MykolaBilyi/terraform-modules//host_keys?ref=v0.10"

  connection = {
    user        = "root"
    private_key = file("~/.ssh/id_rsa")
    host        = "my.domain.com"
  }

  algorithms = ["rsa", "ecdsa"]
  force_regenerate = true
}
```
