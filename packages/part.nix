{ lib, withSystem, ... }:
{
  flake.packages.aarch64-linux = withSystem "aarch64-linux" (
    { pkgs, ... }: import ./default.nix { inherit lib pkgs; }
  );
}
