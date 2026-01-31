{
  pkgs ? (
    let
      flakeLock = (builtins.fromJSON (builtins.readFile ../../flake.lock));
      source =
        with flakeLock.nodes.nixpkgs.locked;
        fetchTarball {
          url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
        };
    in
    import source { }
  ),
}:
let
  nixosSystem =
    args:
    (import "${pkgs.path}/nixos/lib/eval-config.nix") (
      {
        lib = pkgs.lib;
        system = null;
      }
      // args
    );
in
(nixosSystem ({
  modules = [
    (import ../../modules/installer.nix)
  ];
})).config.system.build.isoImage
