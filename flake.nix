{
  description = "A very basic flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

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
    niri-src.url = "github:YaLTeR/niri";
    niri-src.inputs.nixpkgs.follows = "nixpkgs";
    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rmpc = {
      url = "github:mierak/rmpc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    steam-config-nix = {
      url = "github:different-name/steam-config-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri-nix = {
      url = "git+https://codeberg.org/BANanaD3V/niri-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mcp-nixos.url = "github:utensils/mcp-nixos";
    yazi = {
      url = "github:sxyazi/yazi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    t3code-flake = {
      url = "github:Khitboksy/t3code";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };
  outputs =
    inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;
      overlays = [
        (final: prev: {
          openldap = prev.openldap.overrideAttrs (old: {
            doCheck = false;
          });
        })
      ];
      snowfall = {
        namespace = "custom";
      };
      channels-config = {
        allowUnfree = true;
      };
      homes.modules = with inputs; [
        catppuccin.homeModules.catppuccin
        dms.homeModules.dank-material-shell
        niri-nix.homeModules.default
      ];
      systems.modules.nixos = with inputs; [
        home-manager.nixosModules.home-manager
        catppuccin.nixosModules.catppuccin
        yeetmouse.nixosModules.default
        niri-nix.nixosModules.default
        nix-index-database.nixosModules.default
        steam-config-nix.nixosModules.default
      ];
    };
}
