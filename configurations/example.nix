{ ... }:
{
  system = "aarch64-linux";
  modules = [
    "${builtins.fetchTarball "https://github.com/brainwart/x13s-nixos/archive/aef66c462abe817e33aad91d97aa782a1e2ad2c7.zip"}/module.nix"
    (
      { pkgs, ... }:
      {
        nixos-x13s.enable = true;
        nixos-x13s.kernel = pkgs.x13s.linux_jhovold; # jhovold is default, but mainline supported

        # allow unfree firmware
        nixpkgs.config.allowUnfree = true;

        # define your fileSystems
        fileSystems."/".device = "/dev/notreal";
      }
    )
  ];
}
