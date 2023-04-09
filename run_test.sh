#!/usr/bin/env bash

set -fxue

if [ "$1" = "reboot" ]; then
      qemu-system-x86_64 \
 -enable-kvm \
 -drive format=raw,file=disk1.img \
 -drive format=raw,file=disk2.img \
 -m 1G \
 -object rng-random,id=id,filename=/dev/random
fi

if [ "$1" = "rm" ]; then
nix build .#nixosConfigurations.exampleHost.config.system.build.isoImage

rm -f disk1.img disk2.img

 qemu-img create -f raw disk1.img 16G
 qemu-img create -f raw disk2.img 16G

 qemu-system-x86_64 \
 -enable-kvm \
 -cdrom "$(find ./result/iso -type f -name '*.iso' || true)" \
 -drive format=raw,file=disk1.img \
 -drive format=raw,file=disk2.img \
 -nographic \
 -monitor none \
 -serial stdio \
 -m 1G \
 -object rng-random,id=id,filename=/dev/random
 fi
