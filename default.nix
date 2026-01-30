{
  pkgs ? (
    let
      flakeLock = (builtins.fromJSON (builtins.readFile ./flake.lock));
      source =
        with flakeLock.nodes.nixpkgs.locked;
        fetchTarball {
          url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
        };
    in
    import source { }
  ),
}:
(pkgs.lib.packagesFromDirectoryRecursive {
  callPackage = pkgs.callPackage;
  directory = ./packages;
})
