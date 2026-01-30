{
  pkgs ? (import <nixpkgs> { }),
}:
pkgs.mkShellNoCC {
  packages = [
    # editing nix files
    pkgs.nixfmt
    pkgs.nil

    # for use in the update scripts
    pkgs.jq
  ];
}
