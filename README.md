# nixos x13s

This repository aims to provide easy, shared, support for Lenovo X13s on Linux.

The support for this machine is constantly improving in mainline kernel and upstream packages. Eventually the goal is that this repository is no longer necessary.

## Add with a flake

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-x13s.url = "github:BrainWart/x13s-nixos";
  };

  outputs =
    { ... }@inputs:
    {
      nixosConfigurations.example = inputs.nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          inputs.nixos-x13s.nixosModules.default
          {
            nixos-x13s.enable = true;

            nixpkgs.config.allowUnfree = true;
          }
        ];
      };
    };
}
```

## Add using not a flake

Clone the repository:

```
git clone https://github.com/BrainWart/x13s-nixos.git /etc/nixos/nixos-x13s
```

Then reference the module in your `configuration.nix` and use the module as documented in the flake example above:

```nix
  imports =
    [
      ./nixos-x13s/module.nix
    ];
  nixos-x13s.enable = true;
  ...
```

## UEFI Update ISO

This repository provides a package which can output the USB UEFI Update ISO. This will be updated as Lenovo releases new versions.

```
nix build .#x13s.firmware.bios-update-utility

dd if=result/bios_update_utility*.iso of=/path/to/usb/disk
```

Reboot, select USB drive from F12 boot menu, follow wizard.

## Updating packages

```
nix flake upgrade
scripts/getLatestJhovoldLinux.sh > packages/x13s/linux_jhovold/source.json
scripts/getLenovoDownloads.sh > packages/x13s/firmware/lenovo-downloads.json
```

---

Original Repository [unmaintained]:
https://codeberg.org/adamcstephens/nixos-x13s.git
