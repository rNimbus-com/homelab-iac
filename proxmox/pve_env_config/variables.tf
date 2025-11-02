variable "pve_endpoint" {
  type        = string
  description = "Endpoint of the Proxmox host. Example: https://10.0.0.2:8006/"
}

variable "resource_comment" {
  type        = string
  description = "Comment to add to resources (if available)."
  default     = "Managed by OpenTofu"
}

variable "pools" {
  type = list(object({
    pool_id = string,
    comment = optional(string, null)
  }))
  description = "Used to group a set of virtual machines and datastores."
  default     = []
}

variable "nodes" {
  type        = list(string)
  description = "Cluster node names. Only the names, not the FQDN. Example: [ \"pve-host-01\" ]"
}

variable "node_host_entries" {
  type = map(list(object({
    ip_address = string
    hostnames  = list(string)
  })))
  description = "(Optional). Host entries per node, indexed by host name. If set, all host entries must be provided."
  default     = {}
}

variable "dns_search_domain" {
  type        = string
  description = "(Required) The DNS search domain to configure for each node."
}

variable "dns_servers" {
  type        = list(string)
  description = "(Required) The DNS servers to configure for each node."
}

variable "roles" {
  type = list(object({
    role_id    = string
    privileges = list(string)
  }))
  default     = []
  description = "(Optional) Custom roles and their associated privileges."
}

variable "groups" {
  type = list(object({
    group_id = string
    acls = optional(list(object({
      path    = string,
      role_id = string
    })), [])
    comment = optional(string, null)
  }))
  description = <<EOF
        (Optional) List of groups and their ACLs

        group_id (string): (Required) The group identifier.
        
        acls (list(object)): List of Access Control List items for a user.
        - path(string): The path or scope to which the role will be granted for.
        - role_id(string): The role ID to apply. Must either already exists or be set in the `roles` variable.

        comment (string): Optional comment.
    EOF
  default     = []
}

variable "users" {
  type = list(object({
    user_id    = string
    email      = optional(string, null)
    first_name = optional(string, null)
    last_name  = optional(string, null)
    acls = optional(list(object({
      path    = string,
      role_id = string
    })), [])
    groups          = optional(list(string), [])
    enabled         = optional(bool, true)
    expiration_date = optional(string, null)
    comment         = optional(string, null)
  }))
  description = <<EOF
        (Optional) List of users and their ACLs. Will use a password set for the user in `user_passwords`, otherwise generates a random password and output's it.

        user_id (string): The user name/id (without the @pve suffix)
        email (string): (Optional) Email address of the user.
        first_name (string): (Optional) The user's first name.
        last_name (string): (Optional) The user's last name.
        
        acls (list(object)): List of Access Control List items for a user.
        - path(string): The path or scope to which the role will be granted for.
        - role_id(string): The role ID to apply. Must either already exists or be set in the `roles` variable.

        groups (list(string)): (Optional) The user's group ids.

        enabled (bool): (Optional) Whether the user account is enabled.
        expiration_date (string): (Optional) The user account's expiration date (RFC 3339).
        comment (string): Optional comment.
    EOF
  default     = []
}

variable "user_passwords" {
  type        = map(string)
  sensitive   = true
  description = "(Optional) Map of user passwords that aligns with a user_id in the `users[]` list. Passwords are only set when a user is first created. Changes to this value or the users password after user creation are ignored!"
  default     = {}
}