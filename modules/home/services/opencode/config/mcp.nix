{
  inputs,
  system,
  pkgs,
  ...
}:

{
  nixos = {
    type = "local";
    command = [ "${inputs.mcp-nixos.packages.${system}.default}/bin/mcp-nixos" ];
  };
  context7 = {
    type = "remote";
    url = "https://mcp.context7.com/mcp";
  };
  filesystem = {
    type = "local";
    command = [
      "${pkgs.mcp-server-filesystem}/bin/mcp-server-filesystem"
      "/home/helios/builds"
      "/home/helios/shared"
      "/home/helios/.config"
      "/home/helios/repos"
    ];
  };
  github = {
    type = "local";
    command = [
      "${pkgs.github-mcp-server}/bin/github-mcp-server"
      "stdio"
      "--read-only"
    ];
  };
  sequential-thinking = {
    type = "local";
    command = [ "${pkgs.mcp-server-sequential-thinking}/bin/mcp-server-sequential-thinking" ];
  };
  web-search = {
    type = "local";
    command = [
      "npx"
      "-y"
      "@zhafron/mcp-web-search"
    ];
    enabled = true;
    environment = {
      DEFAULT_SEARCH_PROVIDER = "searxng";
      SEARXNG_URL = "https://search.zoeys.computer/search";
    };
  };
  memory-db = {
    type = "local";
    command = [
      "bash"
      "-c"
      "cd /home/helios/.config/opencode/mcps/memory-db-mcp && node server.cjs"
    ];
  };
  bun = {
    type = "local";
    command = [
      "npx"
      "-y"
      "carlosedp/mcp-bun"
    ];
  };

}
