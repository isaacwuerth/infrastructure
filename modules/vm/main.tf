terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      #version = "2.7.4"
    }
    ssh = {
      source = "loafoe/ssh"
    }
    random = {
      source = "hashicorp/random"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
}

resource "random_password" "password" {
  length      = 32
  special     = true
  min_lower   = 8
  min_upper   = 8
  min_numeric = 8
  min_special = 8
}

resource "proxmox_vm_qemu" "itsvc_default" {
  name = var.name
  target_node = var.target_node
  clone = var.clone
  onboot = true
  oncreate = true

  agent = 1
  os_type = "cloud-init"
  cores = var.cores
  sockets = var.sockets
  cpu = "host"
  memory = var.memory
  scsihw = "virtio-scsi-pci"
  bootdisk = "scsi0"
  disk {
    slot = 0
    size = var.disk_size
    type = "scsi"
    storage = "pool01"
    iothread = 1
  }
  
  network {
    model = "virtio"
    bridge = var.network_bridge
  }
  lifecycle {
    ignore_changes = [
      network,
    ]
  }
  
  ipconfig0 = "ip=${var.ipv4addr}/${var.ipv4mask},gw=${var.ipv4gw}"
  ciuser= "${var.username}"
  cipassword = "${var.password == "" ? random_password.password.result : var.password}"
  sshkeys = "${var.sshkeys}"
  cicustom = "vendor=pool01:snippets/vendor-ci.yml"

  provisioner "remote-exec" {
    inline = ["sudo apt update", "sudo apt install python3 -y"]

    connection {
      host        = var.ipv4addr
      type        = "ssh"
      user        = var.username
      private_key = var.ssh_key_private_mgmt
    } 
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ${var.username} -i '${var.ipv4addr},' --private-key /id_rsa -e 'pub_key=${var.ssh_key_public_mgmt}' ${var.ansible_file}"
  }  
}

resource "cloudflare_record" "server_record" {
  zone_id = var.cloudflare_zone_id
  name    = var.name
  value   = var.ipv4addr
  type    = "A"
  ttl     = 3600
  proxied = false
  depends_on = [
    proxmox_vm_qemu.itsvc_default
  ]
}