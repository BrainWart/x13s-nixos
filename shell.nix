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

    # easy script for testing
    (pkgs.writeShellScriptBin "run-tests" ''
      ROOT="$(${pkgs.git}/bin/git rev-parse --show-toplevel)"
      read -r -d ''\'''\' EXPR <<EOF
      builtins.concatStringsSep "\n" (
        builtins.map (
          x: "\''\${x.name}: \''\${
            if (x.expected == x.result) then
              "pass"
            else
            "fail"
          }"
        ) (
          import "$ROOT/tests/testModule.nix" {}
        )
      )
      EOF
      nix eval --impure --raw --expr "$EXPR"
    '')
  ];
}
