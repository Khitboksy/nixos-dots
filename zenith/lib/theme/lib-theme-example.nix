# Notes for humans and agents alike.
#
# This example is purely documentation,
# and is not referenced anywhere in the configuration.
#
# ALL `default.nix` files under modules/ are automatically discovered and
# imported by `collectDefaults` in `lib/zenith/default.nix`:
#
#   - modules/nixos/**/default.nix for system modules.
#   - modules/home/**/default.nix for home-manager modules.
#   - modules/**/*.nix for in-module imports, like themes, or scripts.
#
# ANY files untracked by git are *invisible* to the flake, and will never be
# discovered.

{
  config,
  lib,
  pkgs,
  # inputs, only needed for flake related modules
  ...
}:

# Bring lib.custom helpers into scope
with lib;
with lib.custom;
# lib.custom is assembled in lib/zenith/default.nix by merging
# lib/module/default.nix and lib/theme/default.nix with lib.recursiveUpdate.
# The `colors` helper comes from lib/theme/default.nix and auto-discovers
# every *.json file in lib/theme/colors/ as colors.<palette>.<color>.<type>.

# Define module level variables
let
  cfg = config.apps.term.kitty;
in

{

  # Module options.
  #   We DO NOT define thematic changes here. User customization happens
  #   inside the config block below, not in the home/system/module config where we
  #   enable <module>.
  options.apps.term.kitty = with types; {
    enable = mkBoolOpt false "Enable Kitty";
  };

  # Config options.
  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      package = pkgs.kitty;
      settings = {

        # we exposed the ${colors} attrset with `with lib.custom;`
        # earlier in the module. colors is now a nested attrset of palettes:
        #   colors.<palette>.<color>.<type>
        # e.g. ${colors.helios.<color>.hex} or ${colors.gruvbox-dark.<color>.hex}
        color0 = "${colors.helios.surface1.hex}";
        color8 = "${colors.helios.surface2.hex}";
        color1 = "${colors.helios.red.hex}";
        color9 = "${colors.helios.red.hex}";
        color2 = "${colors.helios.green.hex}";
        color10 = "${colors.helios.green.hex}";
        color3 = "${colors.helios.yellow.hex}";
        color11 = "${colors.helios.yellow.hex}";
        color4 = "${colors.helios.blue.hex}";
        color12 = "${colors.helios.blue.hex}";
        color5 = "${colors.helios.pink.hex}";
        color13 = "${colors.helios.pink.hex}";
        color6 = "${colors.helios.teal.hex}";
        color14 = "${colors.helios.teal.hex}";
        color7 = "${colors.helios.subtext1.hex}";
        color15 = "${colors.helios.subtext0.hex}";

        # if importing from elsewhere in the config
        # `(import ./lib-theme-import-example.nix) { inherit lib; };`
      };

    };
  };

}
