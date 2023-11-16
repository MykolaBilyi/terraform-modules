variable "connection" {
  type = object({
    user        = string
    private_key = optional(string)
    agent       = optional(bool)
    host        = string
  })
}

variable "user_name" {
  type = string
}

variable "public_keys" {
  type    = list(string)
  default = []
}

variable "groups" {
  type    = list(string)
  default = []
}

variable "on_destroy" {
  type    = string
  default = "delete"
  validation {
    condition = contains(["keep", "delete", "delete_keys"], var.on_destroy)
    error_message = "The value of on_destroy must be either \"keep\", \"delete\", or \"delete_keys\""
  }
}
