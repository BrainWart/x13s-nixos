# X13s NixOS

This configuration was built using the following resources:
- https://github.com/LunNova/nixos-configs/blob/dev/hosts/amayadori/x13s.nix
- https://github.com/cenunix/x13s-nixos/tree/main
- NixOS Manual

The following channels must be configured. `mobile-nixos` is used to pull some dependecies as
seen in LunNova's repository. We are not using flakes here yet so we have to get those
dependencies another way.

```
> nix-channel --list
mobile-nixos https://github.com/NixOS/mobile-nixos/archive/refs/heads/master.tar.gz
nixos https://channels.nixos.org/nixos-unstable
```

I was able to successfully follow cenunix's guide using the
[Ubuntu Concepts image](https://launchpad.net/~ubuntu-concept/+archive/ubuntu/x13s).


Do not forget to set a password for your account using `mkpasswd` or the `initialHashedPassword`
option. One can use `mkpasswd` after using `nixos-enter` as invluded in the nixos install tools.

# Quick Steps

1. Build bootable live usb device to boot your laptop with.
2. Install `nix` on in the live environment
  1. `sh <(curl -L https://nixos.org/nix/install) --daemon`
3. Become *root*
  1. `sudo -i`
4. Use nix to get the nixos install tools
  1. `nix-env -IA nixpkgs.nixos-install-tools`
5. Parition and mount your drives
  1. Mount the root partiiton to `/mnt`
  2. Mount the boot partiiton to `/mnt/boot`
  3. Mount other partitions as needed. (swap, etc.)
6. Generate the nixos configuration
  1. `nixos-generate-config --root /mnt`
7. Configure `/mnt/etc/nixos/configuration.nix` to match the file in this repository and
  copy files other than `hardware-configuration.nix` as that file is only included for
  reference.
8. Use `nixos-install` to install NixOS
9. Use `nixos-enter` to temporarily access the system for initial configuration
10. Set up your user password using `mkpasswd`
