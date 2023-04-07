#!/usr/bin/env bash
# assume current directory structure
# ./openzfs-docs/ <- you are here
# ./openzfs-docs/...
# ./openzfs-docs/nixos-live/...

set -xuef

# Install ZFS
add-apt-repository universe
apt update
apt install --yes zfsutils-linux
modprobe zfs

# Create empty disk image
apt install --yes qemu-utils
qemu-img create -f raw zfsroot_disk1.img 16G
qemu-img create -f raw zfsroot_disk2.img 16G
sudo losetup -P $(losetup -f)  zfsroot_disk1.img
sudo losetup -P $(losetup -f)  zfsroot_disk2.img

# Install programs for partitioning
apt install --yes git jq parted

# Install program for mkpasswd
apt install --yes whois

# Clone openzfs-docs repo
# already cloned in Github Action definition
#git clone --depth 1 --branch main https://github.com/ne9z/nixos-live
git -C nixos-live log -n1

# Preprocess document for pylit
sed 's|.. ifconfig:: zfs_root_test|::|g' \
    'docs/Getting Started/NixOS/Root on ZFS.rst' > nixos.rst

# Extract installation shell script from openzfs documentation
nix develop ./nixos-live#build-script --command bash <<EOF
python \
    ./nixos-live/my_pylit.py \
    "nixos.rst" \
    "nixos.sh"
EOF

# check whether nixos.sh have syntax errors
bash -n nixos.sh

# Make the installation script executable and run
chmod a+x nixos.sh
./nixos.sh
