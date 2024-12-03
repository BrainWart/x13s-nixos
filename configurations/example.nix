{
  ...
}:
{
  imports = [
    ../module.nix
  ];

  nixos-x13s.enable = true;

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.11";
}
