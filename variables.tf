variable "sshkey_public" {
  type        = string
  description = "The public SSH key to assign to the VM"
}

variable "sshkey_private" {
  type        = string
  description = "The private SSH key to assign to the VM"
  sensitive = true
}

variable "proxmox_token_id" {
  type        = string
  description = "The token ID of the Proxmox server"  
}

variable "proxmox_token_secret" {
  type        = string
  description = "The token secret of the Proxmox server"  
  sensitive = true
}

variable "cloudflare_api_token" {
  type        = string
  description = "The API token of the Cloudflare account"  
  sensitive = true
}

variable "cloudflare_zone_id" {
  type        = string
  description = "The zone ID of the Cloudflare account"  
}