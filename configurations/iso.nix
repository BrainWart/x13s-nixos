{ pkgs, ... }:
# nix run github:nix-community/nixos-generators -- --flake .#iso -f iso
{
  nixpkgs.config.allowUnfree = true;
  nix = {
    settings.trusted-users = [ "@wheel" ];
    extraOptions = "experimental-features = nix-command flakes";
  };

  nixos-x13s.enable = true;

  services.libinput.enable = true;

  services.xserver.displayManager.gdm = {
    enable = true;
    autoSuspend = false;
  };
  services.xserver.desktopManager.gnome.enable = true;
  services.displayManager.autoLogin = {
    enable = true;
    user = "nixos";
  };
  networking.networkmanager.enable = true;


  environment.defaultPackages = [
    pkgs.gparted
    pkgs.vim
    pkgs.firefox
  ];

  users.users.root.initialHashedPassword = "";
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" ];
    initialHashedPassword = "";
  };

  security.polkit = {
    enable = true;
    extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (subject.isInGroup("wheel")) {
          return polkit.Result.YES;
        }
      });
    '';
  };
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

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

  system.stateVersion = "24.11";
}
