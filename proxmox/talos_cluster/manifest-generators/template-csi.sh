#! /bin/bash
### Note: The .env/proxmox-csi-manifest.yml manifest is already included in this repository. This only needs to be ran if
###       you wish to make changes to the manifest.

# Templates the charts/proxmox-csi-plugin helm chart using the 'proxmox-csi-values.yaml' values file in this 
# directory, saving the output values to an env/manifests/proxmox-csi-manifest.yml.
# If you plan on installing cilium CNI, make sure to set 'talos_cluster.proxmox_csi_enabled=true' 
# in your .env/{your_environment}.tfvars file after templating the charts.
set -e

minify='false'
for arg in "$@"; do
  if [[ "${arg,,}" == "minify" ]]; then
    minify='true'
  fi
done

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
TEMPLATE_VALUES="${SCRIPT_DIR}/values/proxmox-csi-values.yaml"
OUTPUT_MANIFEST="${SCRIPT_DIR}/../.env/manifests/proxmox-csi-manifest.yml"

echo "### Creating Proxmox CSI Plugin Manifest ###"

manifest=$(helm template proxmox-csi-plugin \
    oci://ghcr.io/sergelogvinov/charts/proxmox-csi-plugin \
    --namespace csi-proxmox -f "${TEMPLATE_VALUES}")

if [[ "$minify" == 'true' ]]; then
    echo " **Minifying output manifest with yq**"
    yq '... comments=""' <<< "$manifest" > "$OUTPUT_MANIFEST" 
else
    echo "$manifest" > "$OUTPUT_MANIFEST" 
fi

echo ""
echo "### Templating Complete ###"
echo "Manifest file saved to: $(realpath "${OUTPUT_MANIFEST}")."
echo "Make sure to enable the 'talos_cluster.proxmox_csi_enabled' setting in your tfvars file to enable the installation of Proxmox CCM."