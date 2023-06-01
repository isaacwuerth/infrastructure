variable "name" {
  type        = string
  description = "The name of the VM"
  validation {
    condition     = can(regex("^[a-zA-Z0-9/.]+.itsvc.ch$", var.name))
    error_message = "The name of the VM can only contain alphanumeric characters and dashes."
  }
}

variable "target_node" {
  type        = string
  description = "The name of the node to deploy the VM to"
  default     = "vh01"
}

variable "memory" {
  type        = number
  description = "The amount of memory to allocate to the VM"
  default     = 512
}

variable "cores" {
  type        = number
  description = "The number of cores to allocate to the VM"
  default     = 1
}

variable "sockets" {
  type        = number
  description = "The number of sockets to allocate to the VM"
  default     = 1
}

variable "disk_size" {
  type        = string
  description = "The size of the disk to allocate to the VM"
  default     = "32G"
}

variable "ipv4addr" {
  type        = string
  description = "The IPv4 address to assign to the VM"
  validation {
    condition     = can(regex("[0-9.]+$", var.ipv4addr))
    error_message = "The IPv4 address can only contain numbers and dots."
  }
}

variable "ipv4gw" {
  type        = string
  description = "The IPv4 gateway to assign to the VM"
  validation {
    condition     = can(regex("[0-9.]+$", var.ipv4gw))
    error_message = "The IPv4 gateway can only contain numbers and dots."
  }
}

variable "ipv4mask" {
  type        = string
  description = "The IPv4 mask to assign to the VM"
  validation {
    condition     = can(regex("[1-9][0-9]$", var.ipv4mask))
    error_message = "The IPv4 mask can only contain numbers and dots."
  }
}

variable "username" {
  type        = string
  description = "The username to assign to the VM"
  validation {
    condition     = can(regex("^[a-zA-Z0-9]+$", var.username))
    error_message = "The username can only contain alphanumeric characters."
  }
}

variable "password" {
  type        = string
  description = "The password to assign to the VM"
  default     = ""
  sensitive   = true
}

variable "sshkeys" {
  type        = string
  description = "The SSH keys to assign to the VM"
}

variable "network_bridge" {
  type        = string
  description = "The network bridge to assign to the VM"
  validation {
    condition     = can(regex("^[a-zA-Z0-9]+$", var.network_bridge))
    error_message = "The network bridge can only contain alphanumeric characters."
  }
  default = "vmbr0"
}

variable "template" {
  type        = string
  description = "The name of the template to clone"
  default = "template-ubuntu-22.04"
}

variable "cloudflare_zone_id" {
  type        = string
  description = "The zone ID of the Cloudflare zone"
}

variable "ansible_file" {
  type        = string
  description = "The ansible file to run"
  default = ""
}

variable "ssh_key_public_mgmt" {
  type = string
  description = "The public key to use"
}

variable "ssh_key_private_mgmt" {
  type = string
  description = "The private key for connections"
}