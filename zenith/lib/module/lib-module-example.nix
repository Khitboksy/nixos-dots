# Notes for humans and agents alike.
#
# This example is purely documentation,
# and is not referenced anywhere in the configuration.
#
# This is a rundown of my rough styleguide when creating modules.
#
# ALL `default.nix` files under modules/ are automatically discovered and
# imported by `collectDefaults` in `lib/zenith/default.nix`:
#
#   - modules/nixos/**/default.nix for system modules.
#   - modules/home/**/default.nix for home-manager modules.
#
#   - Files NOT named `default.nix` must be manually imported.
#
# ANY files untracked by git are *invisible* to the flake, and will never be
# discovered.
{
  config,
  lib,
  pkgs,
  # inputs,  only needed for flake related modules
  /*
    you can also omit `pkgs` and add individual pkgs like:
    cowsay,
    kitty,
  */
  ...
}:

# Bring lib.custom helpers into scope
with lib;
with lib.custom;
# lib.custom is assembled in lib/zenith/default.nix by merging
# lib/module/default.nix and lib/theme/default.nix with lib.recursiveUpdate,

# Define module level variables
let
  cfg = config.apps.term.cowsay;
  # system = pkgs.stdenv.hostPlatform.system; only needed for flake/darwin
in

{

  # Module options.
  options.apps.term.cowsay = with types; {
    # Force the default boolean to be false.
    enable = mkBoolOpt false "Enable Cowsay";
    # Enable with <module>.enable=true; inside the respective
    # configuration file (systems/**/*.nix, or homes/**/*.nix)
    #
    #    value    option      default     description
    # - `string = mkStringOpt "10" "Whats the number for";`
    # - `path = mkPathOpt /path/to/thing "Whats the path for";`
  };

  # Config options.
  config = mkIf cfg.enable {
    # This section would be filled with the application specific
    # module options, like `package = `, `settings = `, or `extraConfig = ''...''`
    # or general nix things like `home.packages`, or `environment.variables``

    programs.cowsay = {
      enable = true;
      package = pkgs.cowsay;

      # if importing flake packages;
      # package = inputs.<flake>.packages.${system}.<binary>
    };
  };

}
