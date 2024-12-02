{
  pkgs ? (import <nixpkgs> { }),
}:
pkgs.mkShellNoCC {
  packages = [
    pkgs.nixfmt-rfc-style
    pkgs.nixd
  ];
}
