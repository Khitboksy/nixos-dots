{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser.url = "github:zackartz/zen-browser-flake";
    disko.url = "github:nix-community/disko";
  };

  outputs = inputs:
    inputs.snowfall-lib.mkFlake {
      # You must provide our flake inputs to Snowfall Lib.
      inherit inputs;

      # The `src` must be the root of the flake. See configuration
      # in the next section for information on how you can move your
      # Nix files to a separate directory.
      src = ./.;
      snowfall = {namespace = "custom";};
      channels-config = {
        allowUnfree = true;
      };
      homes.modules = with inputs; [catppuccin.homeManagerModules.catppuccin spicetify-nix.homeManagerModules.default];
      systems.modules.nixos = with inputs; [home-manager.nixosModules.home-manager catppuccin.nixosModules.catppuccin disko.nixosModules.disko];
    };
}
