{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-24.11";
    rtl8812au = {
      url = "github:morrownr/8812au-20210820";
      flake = false;
    };
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
    umu.url = "github:Open-Wine-Components/umu-launcher?dir=packaging/nix";

    zen-browser.url = "github:zackartz/zen-browser-flake";
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
      systems.modules.nixos = with inputs; [home-manager.nixosModules.home-manager catppuccin.nixosModules.catppuccin];
    };
}
