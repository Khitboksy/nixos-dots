{
  # Unscoped abbreviations
  ga = {
    expansion = "git add";
  };

  gc = {
    expansion = "git commit";
  };

  gu = {
    expansion = "git push";
  };

  gd = {
    expansion = "git pull";
  };

  gco = {
    expansion = "git checkout";
  };

  gsw = {
    expansion = "git switch";
  };

  gb = {
    expansion = "git branch";
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

  grb = {
    expansion = "git rebase";
  };

  # Scoped abbreviations
  # These expand only when preceded by a specific command.

  # git add
  "git_add__all" = {
    name = "a";
    command = "git add";
    expansion = "-A";
  };

  # git commit
  "git_commit__message" = {
    name = "m";
    command = "git commit";
    expansion = "-m";
  };

  "git_commit__amend" = {
    name = "a";
    command = "git commit";
    expansion = "--amend";
  };

  # git commit --amend
  "git_commit_amend__noedit" = {
    name = "n";
    command = "git commit --amend";
    expansion = "--no-edit";
  };

  # git push
  "git_push__origin" = {
    name = "o";
    command = "git push";
    expansion = "origin";
  };

  "git_push__force-lease" = {
    name = "f";
    command = "git push";
    expansion = "--force-with-lease";
  };

  "git_push__force" = {
    name = "ff";
    command = "git push";
    expansion = "--force";
  };

  # git pull
  "git_pull__origin" = {
    name = "o";
    command = "git pull";
    expansion = "origin";
  };

  "git_pull__rebase" = {
    name = "r";
    command = "git pull";
    expansion = "--rebase";
  };

  # git checkout
  "git_checkout__new-branch" = {
    name = "b";
    command = "git checkout";
    expansion = "-b";
  };

  "git_checkout__force-branch" = {
    name = "B";
    command = "git checkout";
    expansion = "-B";
  };

  # git switch
  "git_switch__create" = {
    name = "c";
    command = "git switch";
    expansion = "-c";
  };

  # git branch
  "git_branch__delete" = {
    name = "d";
    command = "git branch";
    expansion = "--delete";
  };

  "git_branch__delete-force" = {
    name = "D";
    command = "git branch";
    expansion = "--delete --force";
  };

  "git_branch__move" = {
    name = "m";
    command = "git branch";
    expansion = "--move";
  };

  "git_branch__all" = {
    name = "a";
    command = "git branch";
    expansion = "--all";
  };

  # git rebase
  "git_rebase__interactive" = {
    name = "i";
    command = "git rebase";
    expansion = "-i";
  };

  "git_rebase__continue" = {
    name = "c";
    command = "git rebase";
    expansion = "--continue";
  };

  "git_rebase__skip" = {
    name = "s";
    command = "git rebase";
    expansion = "--skip";
  };

  "git_rebase__abort" = {
    name = "a";
    command = "git rebase";
    expansion = "--abort";
  };
}
