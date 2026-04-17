{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with lib.custom; let
  cfg = config.services.opencode;
in {
  options.services.opencode = {
    enable = mkBoolOpt false "Enable OpenCode AI coding agent";

    package = mkOpt types.package (pkgs.opencode or pkgs.opencode-ai) "OpenCode package";

    defaultModel = mkOpt types.str "openrouter/chatgpt-4o-latest" "Default model";

    settings = mkOpt (types.attrsOf types.anything) {
      "providers" = {
        "openrouter" = {
          apiKey = "file:${config.home.homeDirectory}/.secrets/openrouter.key";
          "default-model" = "openrouter/chatgpt-4o-latest";
          "free-model-default" = "openrouter/chatgpt-4o-latest";
        };
      };
    } "OpenCode settings";
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];

    xdg.configFile."opencode/settings.json".text = builtins.toJSON cfg.settings;
  };
}
