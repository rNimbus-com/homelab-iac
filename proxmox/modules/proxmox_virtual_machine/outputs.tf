output "vm_id" {
    description = "ID of the virtual machine."
    value = proxmox_virtual_environment_vm.this.vm_id
}
output "vm_name" {
    description = "Name of the virtual machine."
    value = proxmox_virtual_environment_vm.this.name
}

output "node_name" {
    description = "Node the virtual machine was deployed to."
    value = proxmox_virtual_environment_vm.this.node_name
}

output "ipv4_addresses" {
    description = "The IPv4 addresses per network interface published by the QEMU agent (empty list when agent.enabled is false)."
    value = proxmox_virtual_environment_vm.this.ipv4_addresses
}

output "ipv6_addresses" {
    description = "The IPv6 addresses per network interface published by the QEMU agent (empty list when agent.enabled is false)."
    value = proxmox_virtual_environment_vm.this.ipv6_addresses
}

output "network_interface_names" {
    description = "The network interface names published by the QEMU agent (empty list when agent.enabled is false)."
    value = proxmox_virtual_environment_vm.this.network_interface_names
}