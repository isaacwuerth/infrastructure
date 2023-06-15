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
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
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

provider "docker" {
  host     = "ssh://itsvcadmin@10.0.10.100:22"
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
}

module "webtools-itsvc-ch" {
  count = 4
  source = "./modules/vm"
  cloudflare_zone_id = var.cloudflare_zone_id
  name = "k8s-host-${count.index}.itsvc.ch"
  cores = 4
  sockets = 1
  memory = 4096
  disk_size = "100G"
  ipv4addr = "10.0.10.11${count.index}"
  ipv4gw = "10.0.10.1"
  ipv4mask = "24"
  network_bridge = "vmbr0"
  username = "itsvcadmin"
  sshkeys = <<-EOT
    ${var.ssh_key_public_mgmt}
    ${var.ssh_key_public_admin}
  EOT
  ssh_key_public_mgmt = var.ssh_key_public_mgmt
  ssh_key_private_mgmt = var.ssh_key_private_mgmt
  ansible_file = "./ansible/prov.yml"
}