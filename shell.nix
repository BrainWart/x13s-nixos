{
  pkgs ? (import <nixpkgs> { }),
}:
pkgs.mkShellNoCC {
  packages = [
    # editing nix files
    pkgs.nixfmt-rfc-style
    pkgs.nixd

    # for use in the update scripts
    pkgs.jq
  ];
}
