## Useful things about ZFS

#### Creating a ZFS pool
```terminal
# zpool create -o ashift=13 -O autotrim=on -O normalization=formD -O encryption=aes-256-gcm -O keyformat=passphrase -O keylocation=file:///path/to/key -O acltype=posix -O canmount=off -O devices=off -O recordsize=64K -O atime=off -O xattr=sa -m none pool_name mirror /dev/disk/by-id/disk1-part2 /dev/disk/by-id/disk2-part2
```

- ashift=12 for 4k blocks
- ashift=13 for 8k blocks
- autotrim for SSD
- recordsize 64K for VM disks

[ZFS tuning cheatsheet](https://jrs-s.net/2018/08/17/zfs-tuning-cheat-sheet/)
