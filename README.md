# nixos x13s

This repository aims to provide easy, shared, support for Lenovo X13s on Linux.

The support for this machine is constantly improving in mainline kernel and upstream packages. Eventually the goal is that this repository is no longer necessary.

## Add with a flake

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-x13s.url = "git+https://codeberg.org/adamcstephens/nixos-x13s";
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

            # allow unfree firmware
            nixpkgs.config.allowUnfree = true;

            # define your fileSystems
            fileSystems."/".device = "/dev/notreal";
          }
        ];
      };
    };
}
```

## Add using not a flake

Not documented, but feel free to submit a PR.
