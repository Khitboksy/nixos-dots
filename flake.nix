{
  description = "A very basic flake";

  # Applied at eval/build time (before /etc/nix/nix.conf is activated):
  # yazi's de-followed drv matches its CI exactly, so the first ns after
  # editing substitutes instead of compiling. Nix asks once to trust this.
  nixConfig = {
    extra-substituters = [ "https://yazi.cachix.org" ];
    extra-trusted-public-keys = [ "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k=" ];
  };

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
      url = "github:MithicSpirit/niri/force-render-v2";
      # Must follow nixpkgs: niri dlopens system Mesa (/run/opengl-driver),
      # so a pinned older nixpkgs here means a glibc ABI mismatch (niri built
      # against glibc 2.42, mesa needing GLIBC_2.43) and a headless hang.
      # Trade-off: no public cache for this fork, so it rebuilds on nsu bumps.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri-nix = {
      url = "git+https://codeberg.org/BANanaD3V/niri-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rmpc = {
      url = "github:mierak/rmpc";
      # Don't follow nixpkgs — master pin (rmpcd, hot-reload fixes) builds
      # against its own flake.lock instead of recompiling on every nsu.
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
      # Don't follow nixpkgs — pinned through its own flake.lock, so root
      # nixpkgs bumps (nsu) no longer rebuild yazi; only yazi's own updates do.
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
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
      # Don't follow nixpkgs — own flake.lock, stable across nsu bumps.
    };

    palette = {
      url = "github:khitboksy/palette-tui";
      # Don't follow nixpkgs — own flake.lock, stable across nsu bumps.
    };

    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
    };

    nix-gaming-edge = {
      url = "github:powerofthe69/nix-gaming-edge";
    };

    playit = {
      url = "github:pedorich-n/playit-nixos-module";
      inputs.nixpkgs.follows = "nixpkgs";
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

      zenith = import ./zenith { inherit inputs lib; };

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
        playit.nixosModules.default
      ];

      homeModules = with inputs; [
        catppuccin.homeModules.catppuccin
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
        # add packages inside `pkgs.custom`
        custom = (prev.custom or { }) // {
          enc = final.callPackage ./packages/enc { };
          danklrc = final.callPackage ./packages/danklrc { };

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
          inherit
            overlays
            nixosModules
            homeModules
            zenith
            ;
        };
        terra = zenith.mkSystem {
          host = "terra";
          homeConfig = "${./.}/homes/x86_64-linux/helios@terra";
          inherit
            overlays
            nixosModules
            homeModules
            zenith
            ;
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
