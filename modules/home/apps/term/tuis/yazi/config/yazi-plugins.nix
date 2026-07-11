{ pkgs }:
{
  bookmarks = pkgs.yaziPlugins.bookmarks;
  drag = pkgs.yaziPlugins.drag.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace main.lua \
        --replace-fail 'tostring(u)' 'tostring(u.url)'
    '';
  });
  smart-paste = pkgs.yaziPlugins.smart-paste;
  compress = pkgs.yaziPlugins.compress;
  mount = pkgs.yaziPlugins.mount;
  nav-parent-panel = pkgs.yaziPlugins.nav-parent-panel;
  jump-to-char = pkgs.yaziPlugins.jump-to-char;
  glow = pkgs.yaziPlugins.glow;
}
