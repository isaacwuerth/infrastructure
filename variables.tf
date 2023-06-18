variable "ssh_key_public_admin" {
  type        = string
  description = "The admin public SSH key to assign to the VM"
}

variable "ssh_key_public_mgmt" {
  type        = string
  description = "The management public SSH key to assign to the VM"
}

variable "ssh_key_private_mgmt" {
  type        = string
  description = "The management private SSH key to assign to the VM"
  sensitive = true
}

variable "proxmox_server" {
  type        = string
  description = "The IP of the Proxmox server"  
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

variable "cloudflare_account_id" {
  type = string
  description = "The ID of the Cloudflare account"
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