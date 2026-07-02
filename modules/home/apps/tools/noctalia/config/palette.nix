{ lib }:
let
  colors = lib.custom.colors;
in
{
  helios-catppuccin = {
    dark = {
      mPrimary = "${colors.mauve.hex}";
      mOnPrimary = "${colors.base.hex}";
      mSecondary = "${colors.lavender.hex}";
      mOnSecondary = "${colors.base.hex}";
      mTertiary = "${colors.blue.hex}";
      mOnTertiary = "${colors.base.hex}";
      mError = "${colors.red.hex}";
      mOnError = "${colors.base.hex}";
      mSurface = "${colors.base.hex}";
      mOnSurface = "${colors.text.hex}";
      mSurfaceVariant = "${colors.surface0.hex}";
      mOnSurfaceVariant = "${colors.subtext0.hex}";
      mOutline = "${colors.surface2.hex}";
      mShadow = "${colors.crust.hex}";
      mHover = "${colors.surface1.hex}";
      mOnHover = "${colors.text.hex}";
      terminal = {
        foreground = "${colors.text.hex}";
        background = "${colors.base.hex}";
        cursor = "${colors.mauve.hex}";
        cursorText = "${colors.base.hex}";
        selectionFg = "${colors.base.hex}";
        selectionBg = "${colors.mauve.hex}";
        normal = {
          black = "${colors.surface1.hex}";
          red = "${colors.red.hex}";
          green = "${colors.green.hex}";
          yellow = "${colors.yellow.hex}";
          blue = "${colors.blue.hex}";
          magenta = "${colors.mauve.hex}";
          cyan = "${colors.sky.hex}";
          white = "${colors.text.hex}";
        };
        bright = {
          black = "${colors.overlay0.hex}";
          red = "${colors.maroon.hex}";
          green = "${colors.green.hex}";
          yellow = "${colors.peach.hex}";
          blue = "${colors.sapphire.hex}";
          magenta = "${colors.pink.hex}";
          cyan = "${colors.teal.hex}";
          white = "${colors.subtext1.hex}";
        };
      };
    };
    light = {
      mPrimary = "${colors.mauve.hex}";
      mOnPrimary = "${colors.base.hex}";
      mSecondary = "${colors.lavender.hex}";
      mOnSecondary = "${colors.base.hex}";
      mTertiary = "${colors.blue.hex}";
      mOnTertiary = "${colors.base.hex}";
      mError = "${colors.red.hex}";
      mOnError = "${colors.base.hex}";
      mSurface = "${colors.base.hex}";
      mOnSurface = "${colors.text.hex}";
      mSurfaceVariant = "${colors.surface0.hex}";
      mOnSurfaceVariant = "${colors.subtext0.hex}";
      mOutline = "${colors.surface2.hex}";
      mShadow = "${colors.crust.hex}";
      mHover = "${colors.surface1.hex}";
      mOnHover = "${colors.text.hex}";
      terminal = {
        foreground = "${colors.text.hex}";
        background = "${colors.base.hex}";
        cursor = "${colors.mauve.hex}";
        cursorText = "${colors.base.hex}";
        selectionFg = "${colors.base.hex}";
        selectionBg = "${colors.mauve.hex}";
        normal = {
          black = "${colors.surface1.hex}";
          red = "${colors.red.hex}";
          green = "${colors.green.hex}";
          yellow = "${colors.yellow.hex}";
          blue = "${colors.blue.hex}";
          magenta = "${colors.mauve.hex}";
          cyan = "${colors.sky.hex}";
          white = "${colors.text.hex}";
        };
        bright = {
          black = "${colors.overlay0.hex}";
          red = "${colors.maroon.hex}";
          green = "${colors.green.hex}";
          yellow = "${colors.peach.hex}";
          blue = "${colors.sapphire.hex}";
          magenta = "${colors.pink.hex}";
          cyan = "${colors.teal.hex}";
          white = "${colors.subtext1.hex}";
        };
      };
    };
  };
}
