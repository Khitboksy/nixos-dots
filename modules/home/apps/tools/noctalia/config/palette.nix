{ lib, zenith }:
let
  colors = zenith.lib'.colors;
in
{
  helios-catppuccin = {
    dark = {
      mPrimary = "${colors.helios.mauve.hex}";
      mOnPrimary = "${colors.helios.base.hex}";
      mSecondary = "${colors.helios.lavender.hex}";
      mOnSecondary = "${colors.helios.base.hex}";
      mTertiary = "${colors.helios.blue.hex}";
      mOnTertiary = "${colors.helios.base.hex}";
      mError = "${colors.helios.red.hex}";
      mOnError = "${colors.helios.base.hex}";
      mSurface = "${colors.helios.base.hex}";
      mOnSurface = "${colors.helios.text.hex}";
      mSurfaceVariant = "${colors.helios.surface0.hex}";
      mOnSurfaceVariant = "${colors.helios.subtext0.hex}";
      mOutline = "${colors.helios.surface2.hex}";
      mShadow = "${colors.helios.crust.hex}";
      mHover = "${colors.helios.surface1.hex}";
      mOnHover = "${colors.helios.text.hex}";
      terminal = {
        foreground = "${colors.helios.text.hex}";
        background = "${colors.helios.base.hex}";
        cursor = "${colors.helios.mauve.hex}";
        cursorText = "${colors.helios.base.hex}";
        selectionFg = "${colors.helios.base.hex}";
        selectionBg = "${colors.helios.mauve.hex}";
        normal = {
          black = "${colors.helios.surface1.hex}";
          red = "${colors.helios.red.hex}";
          green = "${colors.helios.green.hex}";
          yellow = "${colors.helios.yellow.hex}";
          blue = "${colors.helios.blue.hex}";
          magenta = "${colors.helios.mauve.hex}";
          cyan = "${colors.helios.sky.hex}";
          white = "${colors.helios.text.hex}";
        };
        bright = {
          black = "${colors.helios.overlay0.hex}";
          red = "${colors.helios.maroon.hex}";
          green = "${colors.helios.green.hex}";
          yellow = "${colors.helios.peach.hex}";
          blue = "${colors.helios.sapphire.hex}";
          magenta = "${colors.helios.pink.hex}";
          cyan = "${colors.helios.teal.hex}";
          white = "${colors.helios.subtext1.hex}";
        };
      };
    };
    light = {
      mPrimary = "${colors.helios.mauve.hex}";
      mOnPrimary = "${colors.helios.base.hex}";
      mSecondary = "${colors.helios.lavender.hex}";
      mOnSecondary = "${colors.helios.base.hex}";
      mTertiary = "${colors.helios.blue.hex}";
      mOnTertiary = "${colors.helios.base.hex}";
      mError = "${colors.helios.red.hex}";
      mOnError = "${colors.helios.base.hex}";
      mSurface = "${colors.helios.base.hex}";
      mOnSurface = "${colors.helios.text.hex}";
      mSurfaceVariant = "${colors.helios.surface0.hex}";
      mOnSurfaceVariant = "${colors.helios.subtext0.hex}";
      mOutline = "${colors.helios.surface2.hex}";
      mShadow = "${colors.helios.crust.hex}";
      mHover = "${colors.helios.surface1.hex}";
      mOnHover = "${colors.helios.text.hex}";
      terminal = {
        foreground = "${colors.helios.text.hex}";
        background = "${colors.helios.base.hex}";
        cursor = "${colors.helios.mauve.hex}";
        cursorText = "${colors.helios.base.hex}";
        selectionFg = "${colors.helios.base.hex}";
        selectionBg = "${colors.helios.mauve.hex}";
        normal = {
          black = "${colors.helios.surface1.hex}";
          red = "${colors.helios.red.hex}";
          green = "${colors.helios.green.hex}";
          yellow = "${colors.helios.yellow.hex}";
          blue = "${colors.helios.blue.hex}";
          magenta = "${colors.helios.mauve.hex}";
          cyan = "${colors.helios.sky.hex}";
          white = "${colors.helios.text.hex}";
        };
        bright = {
          black = "${colors.helios.overlay0.hex}";
          red = "${colors.helios.maroon.hex}";
          green = "${colors.helios.green.hex}";
          yellow = "${colors.helios.peach.hex}";
          blue = "${colors.helios.sapphire.hex}";
          magenta = "${colors.helios.pink.hex}";
          cyan = "${colors.helios.teal.hex}";
          white = "${colors.helios.subtext1.hex}";
        };
      };
    };
  };
}
