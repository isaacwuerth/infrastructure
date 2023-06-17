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

resource "ssh_resource" "cloud_init_vendor" {
  host = var.proxmox_server
  user = "root"
  private_key = "${var.ssh_key_private_mgmt}"
  file {
    content     = file("cloudinit.yml")
    destination = "/mnt/pve/pool01/snippets/cloudinit.yml"
    permissions = "0644"
  }
}
