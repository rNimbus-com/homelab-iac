data "proxmox_virtual_environment_role" "k8sCCM" {
  role_id = "k8sCCM"
}
data "proxmox_virtual_environment_role" "k8sCSI" {
  role_id = "k8sCSI"
}

# Create Users needed by Proxmox CCM and CSI
resource "proxmox_virtual_environment_user" "kubernetes_ccm" {
  comment = "Proxmox Cloud Controller Manager - Managed by OpenTofu"
  email   = "kubernetes_ccm@pve"
  enabled = true
  user_id = "kubernetes_ccm@pve"
  acl {
    path      = "/"
    propagate = true
    role_id   = data.proxmox_virtual_environment_role.k8sCCM.id
  }
}

resource "proxmox_virtual_environment_user" "kubernetes_csi" {
  comment = "Proxmox CSI Plugin token - Managed by OpenTofu"
  email   = "kubernetes_csi@pve"
  enabled = true
  user_id = "kubernetes_csi@pve"
  acl {
    path      = "/"
    propagate = true
    role_id   = data.proxmox_virtual_environment_role.k8sCSI.id
  }
}

resource "proxmox_virtual_environment_user_token" "ccm" {
  comment               = "Proxmox Cloud Controller Manager - Managed by OpenTofu"
  token_name            = "ccm"
  user_id               = proxmox_virtual_environment_user.kubernetes_ccm.user_id
  privileges_separation = false
}

resource "proxmox_virtual_environment_user_token" "csi" {
  comment               = "Proxmox CSI Plugin token - Managed by OpenTofu"
  token_name            = "csi"
  user_id               = proxmox_virtual_environment_user.kubernetes_csi.user_id
  privileges_separation = false
}

locals {
  # Config file for the proxmox ccm secret
  proxmox_ccm_config = yamlencode({
    clusters = [{
      url      = "${var.pve_cluster_endpoint}/api2/json"
      insecure = true
      token_id = proxmox_virtual_environment_user_token.ccm.id
      # Strip the token id from the front of the secret
      token_secret = replace(proxmox_virtual_environment_user_token.ccm.value, "${proxmox_virtual_environment_user_token.ccm.id}=", "")
      region       = var.talos_cluster.region
    }]
  })
  # Create kubernetes secret manifest with above config
  proxmox_ccm_secret = yamlencode(
    {
      apiVersion = "v1"
      kind       = "Secret"
      type       = "Opaque"
      metadata = {
        name      = "proxmox-cloud-controller-manager"
        namespace = "kube-system"
      }
      data = {
        "config.yaml" = base64encode(local.proxmox_ccm_config)
      }
    }
  )

  # Config file for the proxmox ccm secret
  proxmox_csi_config = yamlencode({
    clusters = [{
      url          = "${var.pve_cluster_endpoint}/api2/json"
      insecure     = true
      token_id     = proxmox_virtual_environment_user_token.csi.id
      token_secret = replace(proxmox_virtual_environment_user_token.csi.value, "${proxmox_virtual_environment_user_token.csi.id}=", "")
      region       = var.talos_cluster.region
    }]
  })
  # Create kubernetes secret manifest with above config
  proxmox_csi_secret = yamlencode(
    {
      apiVersion = "v1"
      kind       = "Secret"
      type       = "Opaque"
      metadata = {
        name      = "proxmox-csi-plugin"
        namespace = "csi-proxmox"
      }
      data = {
        "config.yaml" = base64encode(local.proxmox_csi_config)
      }
    }
  )
}