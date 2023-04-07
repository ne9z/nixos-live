#!/usr/bin/env bash
# wait for networking to complete initialization
set -fxue

if [ $(tty) == "/dev/ttyS0" ]; then

sleep 16

git clone --branch main https://github.com/ne9z/nixos-live
git clone --depth 1 --branch main https://github.com/ne9z/openzfs-docs

sed 's|.. ifconfig:: zfs_root_test|::|g' \
    'openzfs-docs/docs/Getting Started/NixOS/Root on ZFS.rst' > nixos.rst

nix develop ./nixos-live#build-script --command bash <<EOF
python \
    ./nixos-live/my_pylit.py \
    "nixos.rst" \
    "nixos.sh"
EOF

# check whether nixos.sh have syntax errors
bash -n nixos.sh

chmod a+x nixos.sh
./nixos.sh
fi
