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
  pm_parallel = 2

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

module "k8s-itsvc-ch" {
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

module "webtools-itsvc-ch" {
  source = "./modules/vm"
  cloudflare_zone_id = var.cloudflare_zone_id
  name = "webtools.itsvc.ch"
  cores = 4
  sockets = 1
  memory = 4096
  disk_size = "100G"
  ipv4addr = "10.0.10.120"
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
  ansible_file = "./ansible/webtools.yml"
}

resource "cloudflare_tunnel_config" "sdx" {
  account_id = var.cloudflare_account_id
  tunnel_id  = "342fb598-dc12-4f15-a9f4-569f68d2b471"

  config {
    warp_routing {
      enabled = true
    }
    ingress_rule {
      hostname = "sdx"
      path     = "/"
      service  = "http://10.0.10.120"
      origin_request {
        no_tls_verify = true
      }
    }
  }
}