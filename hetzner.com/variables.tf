variable "name" {
  type = string
  default = "server"
}

variable "hetzner_vps_type" {
  type = string
  default = "cx11"
}

variable "hetzner_vps_image" {
  type = string
  default = "ubuntu-22.04"
}

variable "hetzner_datacenter" {
  type = string
  default = "fsn1-dc14"
}

variable "hetzner_labels" {
  type = map(string)
  default = { }
}

variable "public_key" {
  type = string
}

variable "domain_name" {
  type = string
  default = ""
}

variable "init_script" {
  type = string
  default = ""
}