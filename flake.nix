{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";
    umu.url = "github:Open-Wine-Components/umu-launcher?dir=packaging/nix";

    zen-browser.url = "github:zackartz/zen-browser-flake";
    yeetmouse = {
      url = "github:AndyFilter/YeetMouse?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #ciderd = {
    #  url = "git+https://code.zoeys.cloud/zoey/ciderd";
    #
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
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
      homes.modules = with inputs; [catppuccin.homeModules.catppuccin];
      systems.modules.nixos = with inputs; [home-manager.nixosModules.home-manager catppuccin.nixosModules.catppuccin yeetmouse.nixosModules.default];
    };
}
