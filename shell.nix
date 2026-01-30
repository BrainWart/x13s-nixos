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
pkgs.mkShellNoCC {
  packages = [
    # editing nix files
    pkgs.nixfmt
    pkgs.nil

    # for use in the update scripts
    pkgs.jq
  ];
}
