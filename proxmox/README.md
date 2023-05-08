## Proxmox
A bunch of scripts and configs that are relevant for Proxmox installation

### Automatic pool decryption
The `etc/systemd/system/eject-disk@.service`, `etc/systemd/system/zfs-load-keys.service` and `usr/local/sbin/eject-disk.sh` work in tandem to allow unlocking the ZFS pools using an external USB thumb drive. Once the system is booted and keys are loaded for all the pools, the USB drive will be powered down and can be safely removed from the system.

Systemd is all weird when it comes to dashes, so in order to enable the `eject-disk@.service` one can use the `systemd-escape` tool, for example:

```terminal
# systemctl enable eject-disk@$( systemd-escape my-disk-uuid )
```

### Remove license nagging on log-in
Use the `etc/apt/apt.conf.d/99license-notification-remover` to automatically patch the `proxmox-widget-toolkit` package and disable the "No valid subscription" dialog every time a user logs into the Proxmox web console.

### Automatically unlocking the root LUKS partition with a USB key

1. Make sure that `/etc/initramfs-tools/modules` file contains the `uas` module to allow accessing USB devices in the early initramfs environment.
1. Use the `luks-pass.sh` script to provide passphrase.
1. Configure `/etc/crypttab` to use the script: `foo UUID=xxxxxx usb_partuuid luks,keyscript=/path/to/luks-pass.sh`
1. Use the `eject-disk.sh` and `eject-disk@.service` to automatically turn off the USB drive after the system is successfully booted.
    1. Place the `eject-disk.sh` script into the `/usr/local/sbin` directory and make it executable.
    1. Place the `eject-disk@.service` into the `/etc/systemd/system` directory. Can drop the `After=zfs-load-keys.service`, which is only useful for ZFS pool decryption.
    1. Enable the service using the `systemctl enable eject-disk@$( systemd-escape usb_partuuid )` command.

The `luks-pass.sh` script will read raw bytes from the partition with the `usb_partuuid` specified, i.e. `/dev/disk/by-partuuid/usb_partuuid` and will sleep between attempts to give user some time to insert a USB disk. After the system is booted the `eject-disk@.service` will automatically turn off the USB drive and allow it to be safely removed from the system.
