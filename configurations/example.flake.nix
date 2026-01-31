{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-x13s = {
      url = "github:BrainWart/x13s-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: {
    nixosConfigurations.example = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        inputs.nixos-x13s.nixosModules.default
        {
          nixos-x13s.enable = true;
          nixos-x13s.kernel = null; # suppress warning

          nixpkgs.hostPlatform = "aarch64-linux";
          system.stateVersion = "25.11";
        }
      ];
    };
  };
}
