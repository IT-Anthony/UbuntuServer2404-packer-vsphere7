/*
    DESCRIPTION:
    Ubuntu Server 24.04 LTS template
    Last update: 08/01/2024 by MAIRIEN Anthony
    Website: https://blog.tips4tech.fr
*/

// To be able to get the build time
locals {
  buildtime = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
}

// Packer plugin(s)
  packer {
    required_plugins {
      vsphere = {
        version = "1.4.2"
        source  = "github.com/hashicorp/vsphere"
      }
    }
  }

// vSphere provider variables
  variable "vsphere_username" {
    type    = string
    description = "vSphere user account to authenticate to vCenter server."
  }

  variable "vsphere_password" {
    type    = string
    sensitive = true
    description = "vSphere user password to authenticate to vCenter server."
  }

  variable "vsphere_folder" {
    type = string
    description = "Folder to store the template."
    default = "TEMPLATES"
}

  variable "vcenter_server" {
    type    = string
    description = "URL of the vCenter server."
  }

  variable "vsphere_datacenter" {
    type    = string
    description = "vSphere datacenter to use."
  }

  variable "vsphere_cluster" {
    type    = string
    description = "vSphere cluster to use."
  }

  variable "vsphere_datastore" {
    type    = string
    description = "vSphere datastore to use."
  }

  variable "vsphere_network" {
    type    = string
    description = "vSphere cluster to use."
  }

  variable "vsphere_disk_01" {
    type    = number
    description = "Template disk size"
  }

  variable "vsphere_ram" {
    type    = number
    description = "Template RAM size."
  }

  variable "vsphere_cpu" {
    type    = number
    description = "Template CPU size."
  }

  variable "vsphere_vm-name" {
    type    = string
    description = "Template name."
  }

    variable "vm_ssh-username" {
    type    = string
    description = "Template SSH user name to authenticate."
  }

    variable "vm_ssh-password" {
    type    = string
    sensitive = true
    description = "Template SSH user password to authenticate."
  }

// ISO related variables
variable "vsphere_iso_datastore" {
  type        = string
  description = "Datastore where the ISO is stored."
  default     = "STORAGE_MFS"
}

variable "vsphere_iso_path" {
  type        = string
  description = "The path on the vSphere datastore for the ISO image."
  default     = "ISOs"
}

variable "vsphere_iso_file" {
  type        = string
  description = "The file name of the ISO image."
}

// Build sources
  source "vsphere-iso" "ubuntu" {

  // Builder configuration
  insecure_connection = "true"
  iso_paths = ["[${var.vsphere_iso_datastore}] ${var.vsphere_iso_path}/${var.vsphere_iso_file}"]
  vcenter_server = var.vcenter_server
  username = var.vsphere_username
  password = var.vsphere_password
  cluster = var.vsphere_cluster
  datacenter = var.vsphere_datacenter
  datastore = var.vsphere_datastore

  // Template configuration

  // Regardind the $VM_VERSION, please see the documentation -> https://knowledge.broadcom.com/external/article?legacyId=1003746
  vm_name     = var.vsphere_vm-name
  vm_version  = "19"
  guest_os_type = "ubuntu64Guest"
  ssh_username = var.vm_ssh-username
  ssh_password = var.vm_ssh-password
  CPUs = var.vsphere_cpu
  CPU_hot_plug = true
  RAM = var.vsphere_ram
  RAM_hot_plug = true
  tools_upgrade_policy = true
  tools_sync_time      = true
  remove_cdrom         = true
  cdrom_type           = "sata"
  notes = "Packer generated template on ${local.buildtime} - tips4tech.fr"
  convert_to_template = "true"
  ssh_timeout = "20m"
  ip_wait_timeout = "5m"
  boot_order = "disk,cdrom"
  boot_command = [
    "<esc><esc><esc><esc>e<wait5s>", 
    "<leftCtrlOn><aOn><aOff><leftCtrlOff>","<leftCtrlOn><kOn><kOff><leftCtrlOff>", 
    "<leftCtrlOn><aOn><aOff><leftCtrlOff>","<leftCtrlOn><kOn><kOff><leftCtrlOff>",
    "<leftCtrlOn><aOn><aOff><leftCtrlOff>","<leftCtrlOn><kOn><kOff><leftCtrlOff>",
    "<leftCtrlOn><aOn><aOff><leftCtrlOff>","<leftCtrlOn><kOn><kOff><leftCtrlOff>",
    "<leftCtrlOn><aOn><aOff><leftCtrlOff>","<leftCtrlOn><kOn><kOff><leftCtrlOff>",
    "<wait5s>",
    "linux /casper/vmlinuz --- ipv6.disable=1 autoinstall ds=\"nocloud;\"<enter><wait>",
    "initrd /casper/initrd<enter><wait>", 
    "boot<enter>", 
    "<enter><f10><wait>"
  ]  
  boot_wait = "3s"
  pause_before_connecting = "10s"

  // Use floppy/CD instead of Packer webserver, because of Docker environment
  cd_label = "cidata"
  cd_files = [
    "./http/meta-data",
    "./http/user-data"
  ]

  network_adapters {
    network = var.vsphere_network
    network_card = "vmxnet3"
  }

  disk_controller_type = ["pvscsi"]
        storage {
          disk_size = var.vsphere_disk_01
          disk_controller_index = 0
          disk_thin_provisioned = true
        }
  }

  // ISO & cleanup script
  build {
    name = "TPL-UBUNTU-2404"
    sources = ["source.vsphere-iso.ubuntu"]

  provisioner "shell" {
  execute_command = "{{.Vars}} sudo -S -E bash '{{.Path}}'"
  scripts = [
    "scripts/cleanup.sh"
    ]
  }
}
