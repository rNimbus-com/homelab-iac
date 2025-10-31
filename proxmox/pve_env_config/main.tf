# Data References
locals {
  nodes = toset(var.nodes)
}

# Resources

# PVE Host DNS Servers
resource "proxmox_virtual_environment_dns" "first_node_dns_configuration" {
  for_each  = local.nodes
  domain    = var.dns_search_domain
  node_name = each.key
  servers   = var.dns_servers
}

# Manage host file entries
resource "proxmox_virtual_environment_hosts" "nodes" {
  for_each  = var.node_host_entries
  node_name = each.key
  dynamic "entry" {
    for_each = { for hostentry in each.value : hostentry.ip_address => hostentry }
    content {
      address   = entry.value.ip_address
      hostnames = entry.value.hostnames
    }
  }
}