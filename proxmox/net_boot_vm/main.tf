data "proxmox_virtual_environment_file" "image" {
  node_name    = var.image_node_name
  datastore_id = var.image_datastore_id
  content_type = var.image_content_type
  file_name    = var.image_file_name
}

data "proxmox_virtual_environment_file" "vendor" {
  node_name    = var.node_name
  datastore_id = "shared-vz"
  content_type = "snippets"
  file_name    = "vendor-debian-trixie-genericloud-docker.yml"
}

data "proxmox_virtual_environment_file" "user_data" {
  node_name    = var.node_name
  datastore_id = "shared-vz"
  content_type = "snippets"
  file_name    = "user-data-debian-docker.yml"
}

module "bootstrap_vm" {
  # source      = "github.com/rNimbus-com/homelab-iac/proxmox/modules/proxmox_virtual_machine?ref=v0"
  source      = "../modules/proxmox_virtual_machine"
  vm_name     = var.vm_name
  vm_id       = var.vm_id
  node_name   = var.node_name
  description = var.description

  # QEMU Agent can be set to true because the vendor config will install and start it.
  qemu_agent_enabled = true
  # Boot / reboot settings
  start_on_host_boot    = true
  reboot_after_creation = false
  reboot_after_update   = false

  cpu = {
    type      = "host"
    cores     = var.cpu_cores
    cpu_limit = 1
    cpu_units = 1000
  }

  # Boot from virtio0 disk then CD-ROM
  boot_order = ["virtio0", "ide0"]
  # boot_order = [ "virtio0" ]
  disks = [
    {
      interface    = "virtio0"
      datastore_id = "local-cluster-zfs"
      size         = 32
      import_from  = data.proxmox_virtual_environment_file.image.id
    }
  ]

  memory = {
    dedicated_mb      = var.memory_mb
    balooning_enabled = true
  }

  vga = {
    type = "serial0"
  }
  efi_disk = {
    datastore_id = "local-cluster-zfs"
  }

  network_devices = [
    {
      bridge = "vmbr0"
    }
  ]
  cloud_init = {
    datastore_id        = "local-cluster-zfs"
    interface           = "scsi1"
    ip_config           = var.cloud_init_ip_config
    dns                 = var.cloud_init_dns
    vendor_data_file_id = data.proxmox_virtual_environment_file.vendor.id
    user_data_file_id   = data.proxmox_virtual_environment_file.user_data.id
  }
}