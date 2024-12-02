{ pkgs, ... }:
# nix run github:nix-community/nixos-generators -- --flake .#iso -f iso
{
  boot = {
    initrd = {
      systemd.enable = true;
      systemd.emergencyAccess = true;
    };

    loader = {
      grub.enable = false;
      systemd-boot.enable = true;
      systemd-boot.graceful = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

  nixos-x13s = {
    enable = true;
    bluetoothMac = "02:68:b3:29:da:98";
    kernel = pkgs.x13s.linux_jhovold;
  };

  system.stateVersion = "25.05";
}
