locals {
  # Create users map with user_id as the key
  users = { for u in var.users : u.user_id => u }
  # Get a set of user_id's without passwords set in var.user_passwords
  missing_passwords = toset([for uid in keys(local.users) : uid if !contains(nonsensitive(keys(var.user_passwords)), uid)])
  # Get generated passwords for those user's with missing passwords
  generated_passwords = { for uid in local.missing_passwords : uid => {
    generated = true
    password  = random_password.generated[uid].result
  } }
  # Create a map from var.user_passwords that matches the generated_passwords object type
  set_passwords = { for uid, password in var.user_passwords : uid => {
    generated = false
    password  = password
  } }
  # Merge passwords together to a single map
  user_passwords = merge(local.generated_passwords, local.set_passwords)
}

resource "proxmox_virtual_environment_role" "this" {
  for_each   = { for role in var.roles : role.role_id => role }
  role_id    = each.key
  privileges = each.value.privileges
}

# Pools for categorizing VM's and storage
resource "proxmox_virtual_environment_pool" "this" {
  for_each = { for p in var.pools : p.pool_id => p }
  pool_id  = each.value.pool_id
  comment  = each.value.comment != null ? "${each.value.comment} :- ${var.resource_comment}" : var.resource_comment
}

resource "proxmox_virtual_environment_group" "this" {
  for_each = { for g in var.groups : g.group_id => g }
  group_id = each.key
  dynamic "acl" {
    for_each = { for acl in each.value.acls : "${acl.role_id}@${acl.path}" => acl }
    content {
      propagate = true
      path      = acl.value.path
      role_id   = acl.value.role_id
    }
  }
  comment    = each.value.comment != null ? "${each.value.comment} :- ${var.resource_comment}" : var.resource_comment
  depends_on = [proxmox_virtual_environment_role.this]
}

resource "random_password" "generated" {
  for_each         = local.missing_passwords
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "proxmox_virtual_environment_user" "pve_users" {
  for_each = local.users

  user_id    = "${each.key}@pve"
  password   = local.user_passwords[each.key].password
  email      = each.value.email
  first_name = each.value.first_name
  last_name  = each.value.last_name

  dynamic "acl" {
    for_each = { for acl in each.value.acls : "${acl.role_id}@${acl.path}" => acl }
    content {
      propagate = true
      path      = acl.value.path
      role_id   = acl.value.role_id
    }
  }
  groups          = each.value.groups
  enabled         = each.value.enabled
  expiration_date = each.value.expiration_date
  comment         = each.value.comment != null ? "${each.value.comment} :- ${var.resource_comment}" : var.resource_comment

  depends_on = [proxmox_virtual_environment_role.this, proxmox_virtual_environment_group.this]
  # ignore password changes. Only configure on initial user setup
  lifecycle {
    ignore_changes = [password]
  }
}

output "generated_passwords" {
  description = "Passwords that were generate by this terraform. Passwords provided via tfvars will not be shown here."
  # toset([for uid in keys(local.users): uid if !contains(keys(var.user_passwords), uid)])
  value = [for uid, p in local.generated_passwords : {
    user_id  = uid
    password = p.password
  }]
  sensitive = true
}