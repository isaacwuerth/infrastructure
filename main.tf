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


module "operational_github_runner_itsvc_infra" {
  source = "./modules/vm"
  cloudflare_zone_id = var.cloudflare_zone_id
  name = "siem.itsvc.ch"
  cores = 4
  sockets = 1
  memory = 8192
  disk_size = "128G"
  ipv4addr = "10.0.10.110"
  ipv4gw = "10.0.10.1"
  ipv4mask = "24"
  network_bridge = "vmbr1"
  username = "itsvcadmin"
  sshkeys = <<-EOT
    ${var.ssh_key_public_mgmt}
    ${var.ssh_key_public_admin}
  EOT

  provisioner "remote-exec" {
    inline = ["sudo apt update", "sudo apt install python3 -y"]

    connection {
      host        = "10.0.10.110"
      type        = "ssh"
      user        = "root"
      private_key = var.ssh_key_private_mgmt
    } 
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root -i '10.0.10.110,' --private-key /id_rsa -e 'pub_key=${var.ssh_key_public_mgmt}' ./ansible/docker.yml"
  }  
}

