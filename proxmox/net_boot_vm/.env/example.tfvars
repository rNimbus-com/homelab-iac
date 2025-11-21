# Proxmox provider configuration
pve_endpoint="https://pve-host-01.proxmox.local.example.com:8006"
terraform_state_path=".terraform/net_boot_vm_example.tfstate"

# Proxmox image file configuration
image_node_name    = "pve-host-03"
image_datastore_id = "shared-vz"
image_content_type = "import"
image_file_name    = "debian-13-genericcloud-amd64-20251006-2257.qcow2"

# Bootstrap VM configuration
vm_name   = "dns2"
vm_id     = 100
node_name = "pve-host-03"
description = "VM for bootstrapping a network with DHCP and DNS services."
cloud_init_ip_config = [
  {
    ipv4 = {
      address = "192.168.0.200/24"
      gateway = "192.168.0.1"
    }
    dns = {
      domain = "rnimbus.com"
      servers = ["127.0.0.1", "1.1.1.1", "9.9.9.9"]
    }
  }
]