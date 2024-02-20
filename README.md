# nixos x13s

This repository aims to provide easy, shared, support for Lenovo X13s on Linux.

The support for this machine is constantly improving in mainline kernel and upstream packages. Eventually the goal is that this repository is no longer necessary.

## Binary cache

A binary cache is provided through Cachix so you can avoid re-building the kernel.

https://app.cachix.org/cache/nixos-x13s

Ensure you are not overriding the nixpkgs input when consuming this flake, or you may not be able to take advantages of this cache.

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
            nixos-x13s.kernel = "jhovold"; # jhovold is default, but steev and mainline supported

            # install multiple kernels! note this increases eval time for each specialization
            specialisation = {
              mainline.configuration.nixos-x13s.kernel = "mainline";
              steev.configuration.nixos-x13s.kernel = "steev";
            };

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
