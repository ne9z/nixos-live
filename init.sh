#!/usr/bin/env bash
# wait for networking to complete initialization
sleep 20
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

nix-env -f '<nixpkgs>' -iA git

git clone https://github.com/ne9z/nixos-live
cd nixos-live
git checkout dev
git clone https://github.com/ne9z/openzfs-docs
git -C ./openzfs-docs checkout dev
nix develop --command bash <<EOF
cd openzfs-docs
make zfs_root_test
EOF

cp 'openzfs-docs/docs/_build/tests/Root on ZFS/nixos.sh' /root/install.sh
chmod a+x /root/install.sh
/root/install.sh
