terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~>1.44"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~>4.0.4"
    }
  }
}
