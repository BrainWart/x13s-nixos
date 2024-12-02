{
  pkgs ? (import <nixpkgs> { }),
}:
(pkgs.lib.packagesFromDirectoryRecursive {
  callPackage = pkgs.callPackage;
  directory = ./packages;
})
