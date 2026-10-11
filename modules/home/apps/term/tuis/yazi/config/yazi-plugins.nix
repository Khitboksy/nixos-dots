{ pkgs }:
{
  bookmarks = pkgs.yaziPlugins.bookmarks;
  # upstream now uses tostring(u.url) itself; the old postPatch override
  # (tostring(u) -> tostring(u.url)) broke the build with --replace-fail
  drag = pkgs.yaziPlugins.drag;
  smart-paste = pkgs.yaziPlugins.smart-paste;
  compress = pkgs.yaziPlugins.compress;
  mount = pkgs.yaziPlugins.mount;
  nav-parent-panel = pkgs.yaziPlugins.nav-parent-panel;
  jump-to-char = pkgs.yaziPlugins.jump-to-char;
  glow = pkgs.yaziPlugins.glow;
}
