terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.6"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

variable "num_vms" {
  default = 2
}

variable "static_ips" {
  default = ["192.168.122.102", "192.168.122.103"] # Static IPs for the VMs
}

resource "libvirt_volume" "base_volume" {
  name   = "base_volume"
  pool   = "default"
  source = "/home/n7student/ubuntu-20.04-server-cloudimg-amd64.img"
  format = "qcow2"
}

resource "libvirt_volume" "vm_volume" {
  count          = var.num_vms
  name           = "vm${count.index}_disk"
  pool           = "default"
  base_volume_id = libvirt_volume.base_volume.id
  size           = 5 * 1024 * 1024 * 1024 
  format         = "qcow2"
}

data "template_file" "user_data" {
  count = var.num_vms
  template = file("${path.module}/cloud_init.cfg")
  vars = {
    hostname   = "vm_${count.index}"
    fqdn       = "vm_${count.index}.insky.com"
    public_key = file("~/.ssh/id_rsa.pub")
    static_ip  = var.static_ips[count.index] # Assign static IP from the list
  }
}

data "template_cloudinit_config" "cloudinit_config" {
  count         = var.num_vms
  gzip          = false
  base64_encode = false
  part {
    content_type = "text/cloud-config"
    content      = data.template_file.user_data[count.index].rendered
  }
}

resource "libvirt_cloudinit_disk" "vm_cloudinit_disk" {
  count = var.num_vms
  name  = "vm-${count.index}-cloudinit.iso"
  pool  = "default"
  user_data = data.template_cloudinit_config.cloudinit_config[count.index].rendered
}

resource "libvirt_domain" "vm" {
  count = var.num_vms
  name  = "vm${count.index}"
  memory = 2048
  vcpu   = 2

  disk {
    volume_id = libvirt_volume.vm_volume[count.index].id
  }

  network_interface {
    network_name = "default"
    addresses    = [var.static_ips[count.index]] # Static IP for each VM
  }

  cloudinit = libvirt_cloudinit_disk.vm_cloudinit_disk[count.index].id
}
