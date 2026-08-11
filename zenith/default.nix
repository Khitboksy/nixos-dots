{
  inputs,
  lib,
}:

let
  nixpkgs = inputs.nixpkgs;

  # Assemble the custom helpers: merge module + theme
  lib' = lib.recursiveUpdate (import ./lib/module { inherit lib; }) (
    import ./lib/theme { inherit lib; }
  );

  # home-manager lib: extends lib with hm, no custom injection
  _homeLib = lib.extend (final: prev: prev // { hm = inputs.home-manager.lib.hm; });

  # Auto-import
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

  _nixosModules = map (m: import m) (collectDefaults ../modules/nixos);
  _homeModules = map (m: import m) (collectDefaults ../modules/home);

  mkSystem =
    {
      host,
      homeConfig,
      zenith,
      nixosModules ? [ ],
      homeModules ? [ ],
      overlays ? [ ],
    }:
    nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit
          inputs
          zenith
          ;
      };
      modules = [
        ../systems/x86_64-linux/${host}
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
              inherit inputs zenith;
              lib = _homeLib;
            };
            sharedModules = _homeModules ++ homeModules;
            users.helios = import homeConfig;
          };
        }
      ]
      ++ nixosModules
      ++ _nixosModules;
    };

  zenith = {
    inherit
      lib'
      mkSystem
      collectDefaults
      ;
  };

in
zenith
