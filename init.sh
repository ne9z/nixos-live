#!/usr/bin/env bash
# wait for networking to complete initialization
sleep 20

nix-env -f '<nixpkgs>' -iA git

git clone https://github.com/ne9z/nixos-live
cd nixos-live
git checkout dev
git clone https://github.com/ne9z/openzfs-docs
git -C ./openzfs-docs checkout main

sed 's|.. ifconfig:: zfs_root_test|::|g' \
    'openzfs-docs/docs/Getting Started/NixOS/Root on ZFS.rst' > nixos.rst
nix develop --command bash <<EOF
python \
    my_pylit.py \
    "nixos.rst" \
    "nixos.sh"
EOF

chmod a+x nixos.sh
./nixos.sh
