rm -f disk1.img disk2.img

 qemu-img create -f raw disk1.img 16G
 qemu-img create -f raw disk2.img 16G

time qemu-system-x86_64 -enable-kvm \
 -cdrom result/iso/*.iso \
 -drive format=raw,file=disk1.img \
 -drive format=raw,file=disk2.img \
 -nographic \
 -monitor none \
 -serial stdio \
 -m 2G \
 -object rng-random,id=id,filename=/dev/random
