# nixos x13s

This repository aims to provide easy, shared, support for Lenovo X13s on Linux.

The support for this machine is constantly improving in mainline kernel and upstream packages. Eventually the goal is that this repository is no longer necessary.

# Build installation ISO

## Without Flakes
```sh
nix-build -A x13s.installer
```

## With Flakes
```sh
nix build github:BrainWart/x13s-nixos#installer
```

# UEFI Update ISO

This repository provides a package which can output the USB UEFI Update ISO. This will be updated as Lenovo releases new versions.

```sh
nix build .#x13s.firmware.bios-update-utility

dd if=result/bios_update_utility*.iso of=/path/to/usb/disk
```

Reboot, select USB drive from F12 boot menu, follow wizard.

# Updating packages

```sh
nix flake upgrade
scripts/getLatestJhovoldLinux.sh > packages/x13s/linux_jhovold/source.json
scripts/getLenovoDownloads.sh > packages/x13s/firmware/lenovo-downloads.json
```

---



---

Original Repository [unmaintained]:
https://codeberg.org/adamcstephens/nixos-x13s.git
