# Variables for Proxmox provider configuration
variable "pve_endpoint" {
  type        = string
  description = "The Proxmox VE API endpoint URL"
}

variable "terraform_state_path" {
  type        = string
  description = "The local path for storing Terraform state file"
  default     = ".terraform/terraform.tfstate"
}

# Variables for Proxmox image file
variable "image_node_name" {
  type        = string
  description = "The name of node where image file is located"
  default     = "pve-host-01"
}

variable "image_datastore_id" {
  type        = string
  description = "The datastore ID where image file is stored"
  default     = "shared-vz"
}

variable "image_content_type" {
  type        = string
  description = "The content type of the file"
  default     = "iso"
}

variable "image_file_name" {
  type        = string
  description = "The name of the image file"
}
# Variables for control plane VM configuration
variable "vm_name" {
  type        = string
  description = "The name of the virtual machine. This name will be used for cluster identification and DNS resolution."
}

variable "vm_id" {
  type        = number
  description = "Unique ID of the Virtual Machine. Must be a value between 100 and 999,999,999 and unique across the entire Proxmox cluster."
}

variable "node_name" {
  type        = string
  description = "The name of the Proxmox node to assign the virtual machine to."
}

variable "cpu_cores" {
  type        = number
  description = "The amount of vCPU / cores to assign to the the control plane VM."
  default     = 2
}

variable "memory_mb" {
  type        = number
  description = "The amount of memory (in MB) to assign to the the control plane VM."
  default     = 2048
}

variable "description" {
  type        = string
  description = "Description for the virtual machine. Defaults to \"Talos control plane node\"."
  default     = "Talos control plane node"
}

variable "vendor_data_snippet_name" {
  description = "Name of the vendor snippet uploaded to proxmox for cloud-init."
  type = string
  default = null
}

variable "user_data_snippet_name" {
  description = "Name of the user data snippet uploaded to proxmox for cloud-init."
  type = string
  default = null
}

variable "cloud_init_ip_config" {
  type = list(object({
    ipv4 = optional(object({
      address = string
      gateway = optional(string)
    }))
    ipv6 = optional(object({
      address = string
      gateway = optional(string)
    }))
  }))
  description = <<-EOT
List of IP configurations for cloud-init network setup.
- ipv4: (Optional) IPv4 configuration object.
  - address: (Required) IPv4 address in CIDR notation (e.g., "192.168.1.10/24") or "dhcp" for autodiscovery.
  - gateway: (Optional) IPv4 gateway address. Omit if address is set to "dhcp".
- ipv6: (Optional) IPv6 configuration object.
  - address: (Required) IPv6 address in CIDR notation (e.g., "2001:db8::10/64") or "dhcp" for autodiscovery.
  - gateway: (Optional) IPv6 gateway address. Omit if address is set to "dhcp".
EOT
}
variable "cloud_init_dns" {
  type = object({
    domain  = optional(string)
    servers = optional(list(string))
  })
  description = <<-EOT
    (Optional) DNS configuration.
      - domain            (Optional) DNS search domain.
      - servers           (Optional) List of DNS servers.
  EOT
  default = null
}