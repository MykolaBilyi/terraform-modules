variable "string" {
  type        = string
  sensitive   = true
  default     = ""
  description = "Connection string in form of a URI: schema:[//[user[:password]@]host[:port]]path[?query][#fragment]"
}

variable "agent" {
  type        = bool
  default     = false
  description = "Force use of ssh-agent. Variable added for compatibility reasons"
}

variable "private_key" {
  type        = string
  sensitive   = true
  nullable    = true
  default     = null
  description = "Private key to use for authentication. Variable added for compatibility reasons"
}

variable "default_port" {
  type        = number
  default     = null
  nullable    = true
  description = "Connection port when no port specified in the connection string"
}

variable "default_user" {
  type        = string
  default     = null
  nullable    = true
  description = "Connection user when no user specified in the connection string"
}
