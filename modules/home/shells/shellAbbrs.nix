{
  # Simple one-step git abbreviations (unscoped — work fine in Fish 4.x)
  # These expand on space/enter from a single token to the full command.
  # Multi-token shorthands (ga, gc, gu, gd, gco, gsw, gb, grb)
  # have been moved to fish functions for argument-level shorthand support.

  git_abbr = {
    command = "git";
    regex = "(a|m|o|f{1,2}|c|i|s|d|D|r|b|B|n|p|an)";
    function = "__fish_git_abbr_expand";
  };

  gu = {
    expansion = "git push";
  };
  gd = {
    expansion = "git pull";
  };

  ga = {
    expansion = "git add";
  };

  gc = {
    expansion = "git commit";
  };

  gb = {
    expansion = "git branch";
  };

  gr = {
    expansion = "git rebase";
  };

  gsw = {
    expansion = "git switch";
  };

  gco = {
    expansion = "git checkout";
  };

  gs = {
    expansion = "git status";
  };

  gl = {
    expansion = "git log --oneline --graph";
  };

  gdf = {
    expansion = "git diff";
  };

  gcl = {
    expansion = "git clone";
  };

  scl = {
    expansion = "systemctl";
  };

  u = {
    command = "systemctl";
    expansion = "--user";
  };

  r = {
    command = "systemctl";
    expansion = "restart";
  };

  s = {
    command = "systemctl";
    expansion = "start";
  };

  l = {
    command = "systemctl";
    expansion = "status";
  };

}
