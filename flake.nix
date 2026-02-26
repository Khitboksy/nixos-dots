{
  description = "A very basic flake";

  inputs = {
    #nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

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
    #  inputs.nixpkgs.follows = "nixpkgs";};

    niri-src.url = "github:YaLTeR/niri";
    niri-src.inputs.nixpkgs.follows = "nixpkgs";

    niri.url = "github:sodiboo/niri-flake";

    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rmpc = {
      url = "github:mierak/rmpc";

      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.snowfall-lib.mkFlake {
      # You must provide our flake inputs to Snowfall Lib.
      inherit inputs;

      # The `src` must be the root of the flake. See configuration
      # in the next section for information on how you can move your
      # Nix files to a separate directory.
      src = ./.;
      /*
        overlays = with inputs; [
        # rust-overlay.overlays.default
        (final: prev: {
          ghostty = ghostty.packages."x86_64-linux".default;
        })
        # (final: prev: {
        #   shadps4 = prev.shadps4.overrideAttrs {
        #     src = prev.fetchFromGitHub {
        #       owner = "shadps4-emu";
        #       repo = "shadPS4";
        #       rev = "41b39428335025e65f9e707ed8d5a9a1b09ba942";
        #       hash = "sha256-5oe2By8TjJJIVubkp5lzqx2slBR7hxIHV4wZLgRYKl8=";
        #       fetchSubmodules = true;
        #     };
        #     patches = [];
        #   };
        # })
        #niri.overlays.niri
      ];
      */

      snowfall = {namespace = "custom";};
      channels-config = {
        allowUnfree = true;
      };
      homes.modules = with inputs; [
        catppuccin.homeModules.catppuccin
        dms.homeModules.dank-material-shell
        dms.homeModules.niri
      ];
      systems.modules.nixos = with inputs; [
        home-manager.nixosModules.home-manager
        catppuccin.nixosModules.catppuccin
        yeetmouse.nixosModules.default
        niri.nixosModules.niri
      ];
    };
}
