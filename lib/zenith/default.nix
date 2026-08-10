{
  inputs,
  lib,
}:

let
  nixpkgs = inputs.nixpkgs;

  # Assemble lib.custom: merge lib/module + lib/theme into one attrset.
  custom = lib.recursiveUpdate (import ../module { inherit lib; }) (import ../theme { inherit lib; });

  # Create the library injected into NixOS module evaluation.
  systemLib = lib // {
    inherit custom;
  };

  # Create the library injected into home-manager evaluation.
  homeLib = systemLib.extend (
    final: prev:
    systemLib
    // prev
    // {
      hm = inputs.home-manager.lib.hm;
    }
  );

  # Auto-import
  # Collects every `default.nix` under a directory tree
  collectDefaults =
    dir:
    let
      entries = builtins.readDir dir;
      dirs = lib.filterAttrs (_name: type: type == "directory") entries;
      nested = lib.concatMap (d: collectDefaults (dir + "/${d}")) (lib.attrNames dirs);
      own = lib.optional (entries ? "default.nix" && entries."default.nix" == "regular") (
        dir + "/default.nix"
      );
    in
    own ++ nested;

  # Local NixOS and home modules
  nixosModules' = map (m: import m) (collectDefaults ../../modules/nixos);
  homeModules' = map (m: import m) (collectDefaults ../../modules/home);

  # System builder
  mkSystem =
    {
      host,
      homeConfig,
      nixosModules ? [ ],
      homeModules ? [ ],
      overlays ? [ ],
    }:
    nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
        lib = systemLib;
      };
      modules = [
        ../../systems/x86_64-linux/${host}
        {
          nixpkgs.config = {
            allowUnfree = true;
            allowAliases = false;
          };
          nixpkgs.overlays = overlays;
        }
        {
          home-manager = {
            useGlobalPkgs = true;
            extraSpecialArgs = {
              inherit inputs;
              lib = homeLib;
            };
            sharedModules = homeModules' ++ homeModules;
            users.helios = import homeConfig;
          };
        }
      ]
      ++ nixosModules
      ++ nixosModules';
    };

in
{
  inherit
    collectDefaults
    systemLib
    homeLib
    mkSystem
    ;
}
