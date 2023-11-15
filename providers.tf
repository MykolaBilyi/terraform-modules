terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~>1.44"
    }
    ssh = {
      source  = "loafoe/ssh"
      version = "~>2.6.0"
    }
  }
}
