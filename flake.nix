{
  description = "A very basic flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";

    flake-parts.url = "github:hercules-ci/flake-parts";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    yeetmouse = {
      url = "github:AndyFilter/YeetMouse?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri-src = {
      url = "github:niri-wm/niri";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri-nix = {
      url = "git+https://codeberg.org/BANanaD3V/niri-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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

    mcp-nixos.url = "github:utensils/mcp-nixos";

    yazi = {
      url = "github:sxyazi/yazi";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    odysseus = {
      url = "github:pewdiepie-archdaemon/odysseus";
      flake = false;
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      # Don't follow nixpkgs — needed for binary cache
    };

    img2key = {
      url = "github:khitboksy/img2key";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    palette = {
      url = "github:khitboksy/palette-tui";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
    };

    nix-gaming-edge = {
      url = "github:powerofthe69/nix-gaming-edge";
    };
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      home-manager,
      ...
    }:
    let
      lib = nixpkgs.lib;

      zenith = import ./lib/zenith { inherit inputs lib; };

      # Shared modules
      nixosModules = with inputs; [
        home-manager.nixosModules.home-manager
        catppuccin.nixosModules.catppuccin
        yeetmouse.nixosModules.default
        niri-nix.nixosModules.default
        nix-index-database.nixosModules.default
        steam-config-nix.nixosModules.default
        sops-nix.nixosModules.sops
        disko.nixosModules.disko
      ];

      homeModules = with inputs; [
        catppuccin.homeModules.catppuccin
        dms.homeModules.dank-material-shell
        noctalia.homeModules.default
        niri-nix.homeModules.default
        palette.homeModules.default
      ];

      # Overlays and Packages
      ## Overlays
      flakePackages = import ./overlays/flake-packages {
        inherit (inputs)
          img2key
          rmpc
          yazi
          zen-browser
          niri-src
          mcp-nixos
          nix-gaming-edge

          ;
      };

      cachyKernelPin = inputs.nix-cachyos-kernel.overlays.pinned;

      ## Packages
      userPackages = final: prev: {
        # add packages inside the `custom`. this is adding to `lib.custom`
        custom = (prev.custom or { }) // {
          enc = final.callPackage ./packages/enc { };

        };
      };

      overlays = [
        userPackages
        flakePackages
        cachyKernelPin

      ];

    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      flake.nixosConfigurations = {
        helios = zenith.mkSystem {
          host = "helios";
          homeConfig = "${./.}/homes/x86_64-linux/helios@helios";
          inherit overlays nixosModules homeModules;
        };
        terra = zenith.mkSystem {
          host = "terra";
          homeConfig = "${./.}/homes/x86_64-linux/helios@terra";
          inherit overlays nixosModules homeModules;
        };
      };

      perSystem = { pkgs, ... }: {
        formatter = pkgs.nixfmt-tree;

        packages = { };

        devShells = {
          default = import ./shells/default { inherit pkgs; };
          nix = import ./shells/nix { inherit pkgs; };
          rust = import ./shells/rust { inherit pkgs; };
        };

        checks = {
          config-check = import ./checks { inherit pkgs; };
        };
      };
    };
}
