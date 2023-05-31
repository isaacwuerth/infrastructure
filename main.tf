terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
    ssh = {
      source = "loafoe/ssh"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
}

provider "proxmox" {
  pm_api_url = "https://${var.proxmox_server}:8006/api2/json"
  pm_api_token_id = var.proxmox_token_id
  pm_api_token_secret = var.proxmox_token_secret
  pm_tls_insecure = true

  pm_log_enable = true
  pm_log_file   = "terraform-plugin-proxmox.log"
  pm_debug      = true
  pm_log_levels = {
    _default    = "debug"
    _capturelog = ""
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "proxmox_lxc" "multiple_mountpoints" {
  target_node  = "vh01"
  hostname     = "test"
  ostemplate   = "pool01:vztmpl/debian-11-standard_11.6-1_amd64.tar.zst"
  unprivileged = true
  onboot       = true
  start        = true

  ssh_public_keys = <<-EOT
    ${var.sshkey_public}
  EOT

  // Terraform will crash without rootfs defined
  rootfs {
    storage = "pool01"
    size    = "2G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "10.0.10.100/24"
    gw     = "10.0.10.1"
    ip6    = "dhcp"
  }
}