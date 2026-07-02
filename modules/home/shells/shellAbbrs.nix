{
  # Simple one-step git abbreviations (unscoped — work fine in Fish 4.x)
  # These expand on space/enter from a single token to the full command.
  # Multi-token shorthands (ga, gc, gu, gd, gco, gsw, gb, grb)
  # have been moved to fish functions for argument-level shorthand support.

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
}
