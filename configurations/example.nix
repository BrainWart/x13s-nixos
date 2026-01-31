{
  pkgs ? import <nixpkgs> { },
  ...
}:
{
  imports = [
    "${
      pkgs.fetchFromGitHub {
        owner = "BrainWart";
        repo = "x13s-nixos";
        rev = "";
        hash = pkgs.lib.fakeHash;
      }
    }/module.nix"
  ];

  nixos-x13s.enable = true;
  nixos-x13s.kernel = null; # suppress warning

  nixpkgs.hostPlatform = "aarch64-linux";
  system.stateVersion = "25.11";
}
