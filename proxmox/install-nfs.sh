#! /bin/bash
# Requires root or sudo

set -e

if [[ -z "$1" ]]; then
    echo "NFS Server IP or Hostname  argument is required."
    echo "  usage: ./install-nfs.sh {hostname_or_ip}"
    echo "  example: ./install-nfs.sh 'omv.local.example.com'"
    exit 1
fi

nfs_server=$1

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install nfs-common -y

mkdir -p /mnt/iac-state
echo "${nfs_server}:/export/iac-state    /mnt/iac-state/    nfs    defaults    0 0" >> /etc/fstab
mount -a