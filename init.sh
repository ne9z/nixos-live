#!/usr/bin/env bash
# wait for networking to complete initialization
set -vfxue

if [ "$(tty || true)" = "/dev/ttyS0" ]; then

sleep 16

git clone --branch main https://github.com/ne9z/nixos-live
git clone --depth 1 --branch master https://github.com/ne9z/openzfs-docs

nix develop ./nixos-live#build-script --command bash <<-'EOF'
run_test () {
    local path="${1}"
    local distro="${2}"
    sed 's|.. ifconfig:: zfs_root_test|::|g' \
	"${path}" > "${distro}".rst
    sed -i '/highlight:: sh/d' "${distro}".rst

    # Generate installation script from documentation
    python scripts/zfs_root_gen_bash.py "${distro}".rst "${distro}".sh

    # Postprocess script for bash
    sed -i 's|^ *::||g' "${distro}".sh
    # ensure heredocs work
    sed -i 's|^ *ZFS_ROOT_GUIDE_TEST|ZFS_ROOT_GUIDE_TEST|g' "${distro}".sh
    sed -i 's|^ *ZFS_ROOT_NESTED_CHROOT|ZFS_ROOT_NESTED_CHROOT|g' "${distro}".sh
    sed -i 's|^ *EOF|EOF|g' "${distro}".sh

    # check whether nixos.sh have syntax errors
    bash -n "${distro}".sh

    ## !shellcheck does not handle nested chroots
    # create another file with <<EOF construct removed
    sed 's|<<.*||g' "${distro}".sh > "${distro}"-shellcheck.sh
    shellcheck \
        --check-sourced \
        --enable=all \
        --shell=dash \
        --severity=style \
        --format=tty \
        "${distro}"-shellcheck.sh

    # Make the installation script executable and run
    chmod a+x "${distro}".sh
}

cd openzfs-docs
run_test 'docs/Getting Started/NixOS/Root on ZFS.rst' nixos
EOF
./openzfs-docs/nixos.sh nixos
fi
