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

resource "local_sensitive_file" "id_rsa" {
  content = var.ssh_key_private_mgmt
  file_permission = "0600"
  filename = "${path.module}/ssh-${var.name}"
}

resource "proxmox_vm_qemu" "vm" {
  depends_on = [ local_sensitive_file.id_rsa ]
  
  name = var.name
  target_node = var.target_node
  clone = var.template
  onboot = true
  oncreate = true
  boot = "order=scsi0"

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
    iothread = 0
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
  cicustom = "vendor=pool01:snippets/cloudinit.yml"
  cloudinit_cdrom_storage = "pool01"

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
   command = "ansible-galaxy install -r ansible/requirements.yml && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ${var.username} -i '${var.ipv4addr},' --private-key ${path.module}/ssh-${var.name} -e 'pub_key=${var.ssh_key_public_mgmt}' ${var.ansible_file}"
  }  
}
