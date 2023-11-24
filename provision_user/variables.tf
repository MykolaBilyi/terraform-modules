variable "connection" {
  type = object({
    user        = string
    private_key = optional(string)
    agent       = optional(bool)
    host        = string
  })
  description = "Connection details"
}

variable "user_name" {
  type = string
  description = "User name"
  validation {
    condition = can(regex("^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\\$)$", var.user_name))
    error_message = "The value of user_name should be a valid username"
  }
}

variable "shell" {
  type    = string
  default = "/bin/bash"
  description = "Shell to use for the user"
}

variable "groups" {
  type    = list(string)
  default = []
  description = "Groups to add the user to"
}

variable "on_destroy" {
  type    = string
  default = "delete"
  description = "What to do with the user on destroy"
  validation {
    condition = contains(["keep", "delete", "delete_keys"], var.on_destroy)
    error_message = "The value of on_destroy must be either \"keep\", \"delete\", or \"delete_keys\""
  }
}

variable "public_keys" {
  type    = list(string)
  default = []
  description = "Public keys to add to the user's authorized_keys file"
}

variable "command" {
  type    = string
  default = null
  description = "Command to restrict the user to when connecting over SSH"
}

variable "from" {
  type    = list(string)
  default = null
  description = "List of source IP addresses to restrict the user to when connecting over SSH"
}

variable "port-forwarding" {
  type    = bool
  default = true
  description = "Whether to allow port forwarding when connecting over SSH"
}

variable "x11-forwarding" {
  type    = bool
  default = true
  description = "Whether to allow X11 forwarding when connecting over SSH"
}

variable "agent-forwarding" {
  type    = bool
  default = true
  description = "Whether to allow agent forwarding when connecting over SSH"
}

variable "pty" {
  type    = bool
  default = true
  description = "Whether to allow PTY when connecting over SSH"
}
