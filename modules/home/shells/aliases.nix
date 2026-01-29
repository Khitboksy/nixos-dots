{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with pkgs; {
  vpn = "mullvad";
  uuid = "cat /proc/sys/kernel/random/uuid";
  #grep = getExe ripgrep;
  #fzf = getExe skim;
  untar = "tar -xvf";
  untargz = "tar -xzf";
  MANPAGER = "sh -c 'col -bx | bat -l man -p'";
  #du = getExe du-dust;
  #ps = getExe procs;
  #lb = "pw-loopback -C \"alsa_input.pci-0000_0d_00.4.analog-stereo\" -P \"Scarlett Solo (3rd Gen.) Headphones / Line 1-2\"";
  #deploy = "nixos-rebuild switch --flake ~/nixos#pluto --target-host zoeys.computer --use-remote-sudo";
  m = "mkdir -p";
  fcd = "cd $(find -type d | fzf)";
  l = "ls -lF --time-style=long-iso --icons";
  sc = "sudo systemctl";
  scu = "systemctl --user ";
  #la = "${getExe eza} -lah --tree";
  #ls = "${getExe eza} -h --git --icons --color=auto --group-directories-first -s extension";
  #tree = "${getExe eza} --tree --icons --tree";
  kys = "shutdown now";
  #w = ''| nvim -c "setlocal buftype=nofile bufhidden=wipe" -c "nnoremap <buffer> q :q!<CR>" -'';
  lv = "nvim -c \"normal '\''0\"";
  #pf = ''
  #  fzf --bind ctrl-y:preview-up,ctrl-e:preview-down \
  #  --bind ctrl-b:preview-page-up,ctrl-f:preview-page-down \
  #  --bind ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down \
  #  --bind ctrl-k:up,ctrl-j:down \
  #  --preview='bat --style=numbers --color=always --line-range :100 {}'
  #'';
  #gpl = "curl https://www.gnu.org/licenses/gpl-3.0.txt -o LICENSE";
  #agpl = "curl https://www.gnu.org/licenses/agpl-3.0.txt -o LICENSE";
  #tsm = "transmission-remote";
  g = "git";
  gaa = "git add -A";
  gcm = "git commit -m ";

  ns = "nh os switch -- --cores 8 --max-jobs 1";
  nsu = "nh os switch --update -- --cores 8 --max-jobs 1";
  nb = "nh os boot -- --core 8 --max-jobs 1";
  nbu = "nh os boot --update --cores 8 --max-jobs 1";

  #vm = "nixos-rebuild build-vm --flake ~/nixos#earth";
  #mnt = "udisksctl mount -b";
  #umnt = "udisksctl unmount -b";
  burn = "pkill -9";
  diff = "diff --color=auto";
  "v" = "nvim";
  ".." = "cd ..";
  "..." = "cd ../../";
  "...." = "cd ../../../";
  "....." = "cd ../../../../";
  "......" = "cd ../../../../../";
}
