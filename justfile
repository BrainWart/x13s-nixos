all:
    just -l

find-targets:
    nix eval .#packages.aarch64-linux --apply 'builtins.attrNames' --json | jq '. | map(".#" + .) | join(" ")' -r > targets

build:
    nix build --print-out-paths --keep-going $(cat targets) > outputs
    cat outputs

push:
    cachix -- push nixos-x13s $(cat outputs)
