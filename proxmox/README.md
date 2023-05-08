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
