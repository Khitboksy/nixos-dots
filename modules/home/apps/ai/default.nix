{
  lib,
  config,
  ...
}:

with lib;
with lib.custom;

let
  cfg = config.apps.ai;
in

{
  options = {

    apps.ai.enable = mkBoolOpt false "Master switch for all AI apps (opencode, odysseus, mcps, t3code)";

    apps.ai.providers = mkStringListOpt [
      "opencode"
      "opencode-go"
      "openrouter"
    ] "Available AI providers";

    apps.ai.provider = mkStringOpt "opencode" "The default provider for AI apps";

    apps.ai.model = mkStringOpt "opencode/deepseek-v4-flash-free" "The default model for AI apps";

    apps.ai.envFiles = mkPathOpt /run/secrets "Global Environment Variables, and Keys";

  };

  config = mkIf cfg.enable {

    apps.ai.opencode.enable = true;
    apps.ai.odysseus.enable = true;
    apps.ai.t3code.enable = false;

  };
}
