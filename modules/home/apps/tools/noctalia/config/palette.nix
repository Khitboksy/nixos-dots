{ zenith }:
with zenith.lib'.colors;
{
  helios-catppuccin = {
    dark = {
      mPrimary = "${helios.mauve.hex}";
      mOnPrimary = "${helios.base.hex}";
      mSecondary = "${helios.lavender.hex}";
      mOnSecondary = "${helios.base.hex}";
      mTertiary = "${helios.blue.hex}";
      mOnTertiary = "${helios.base.hex}";
      mError = "${helios.red.hex}";
      mOnError = "${helios.base.hex}";
      mSurface = "${helios.base.hex}";
      mOnSurface = "${helios.text.hex}";
      mSurfaceVariant = "${helios.surface0.hex}";
      mOnSurfaceVariant = "${helios.subtext0.hex}";
      mOutline = "${helios.surface2.hex}";
      mShadow = "${helios.crust.hex}";
      mHover = "${helios.surface1.hex}";
      mOnHover = "${helios.text.hex}";
      terminal = {
        foreground = "${helios.text.hex}";
        background = "${helios.base.hex}";
        cursor = "${helios.mauve.hex}";
        cursorText = "${helios.base.hex}";
        selectionFg = "${helios.base.hex}";
        selectionBg = "${helios.mauve.hex}";
        normal = {
          black = "${helios.surface1.hex}";
          red = "${helios.red.hex}";
          green = "${helios.green.hex}";
          yellow = "${helios.yellow.hex}";
          blue = "${helios.blue.hex}";
          magenta = "${helios.mauve.hex}";
          cyan = "${helios.sky.hex}";
          white = "${helios.text.hex}";
        };
        bright = {
          black = "${helios.overlay0.hex}";
          red = "${helios.maroon.hex}";
          green = "${helios.green.hex}";
          yellow = "${helios.peach.hex}";
          blue = "${helios.sapphire.hex}";
          magenta = "${helios.pink.hex}";
          cyan = "${helios.teal.hex}";
          white = "${helios.subtext1.hex}";
        };
      };
    };
    light = {
      mPrimary = "${helios.mauve.hex}";
      mOnPrimary = "${helios.base.hex}";
      mSecondary = "${helios.lavender.hex}";
      mOnSecondary = "${helios.base.hex}";
      mTertiary = "${helios.blue.hex}";
      mOnTertiary = "${helios.base.hex}";
      mError = "${helios.red.hex}";
      mOnError = "${helios.base.hex}";
      mSurface = "${helios.base.hex}";
      mOnSurface = "${helios.text.hex}";
      mSurfaceVariant = "${helios.surface0.hex}";
      mOnSurfaceVariant = "${helios.subtext0.hex}";
      mOutline = "${helios.surface2.hex}";
      mShadow = "${helios.crust.hex}";
      mHover = "${helios.surface1.hex}";
      mOnHover = "${helios.text.hex}";
      terminal = {
        foreground = "${helios.text.hex}";
        background = "${helios.base.hex}";
        cursor = "${helios.mauve.hex}";
        cursorText = "${helios.base.hex}";
        selectionFg = "${helios.base.hex}";
        selectionBg = "${helios.mauve.hex}";
        normal = {
          black = "${helios.surface1.hex}";
          red = "${helios.red.hex}";
          green = "${helios.green.hex}";
          yellow = "${helios.yellow.hex}";
          blue = "${helios.blue.hex}";
          magenta = "${helios.mauve.hex}";
          cyan = "${helios.sky.hex}";
          white = "${helios.text.hex}";
        };
        bright = {
          black = "${helios.overlay0.hex}";
          red = "${helios.maroon.hex}";
          green = "${helios.green.hex}";
          yellow = "${helios.peach.hex}";
          blue = "${helios.sapphire.hex}";
          magenta = "${helios.pink.hex}";
          cyan = "${helios.teal.hex}";
          white = "${helios.subtext1.hex}";
        };
      };
    };
  };
}
