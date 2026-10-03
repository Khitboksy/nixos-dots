{
  lib,
  zenith,
  config,
  ...
}:

with zenith.lib';

let
  cfg = config.apps.ai;
in

{
  options = {

    apps.ai.enable = mkBoolOpt false "Master switch for all AI apps";

    apps.ai.providers = mkStringListOpt [
      "opencode"
      "opencode-go"
      "openrouter"
    ] "Available AI providers";

    apps.ai.provider = mkStringOpt "opencode" "The default provider for AI apps";

    apps.ai.modelMain = mkStringOpt " " "The default model for Orchestrator/User Facing";
    apps.ai.modelSub = mkStringOpt " " "The default model for sub agents";

    apps.ai.envFiles = mkPathOpt /run/secrets "Global Environment Variables, and Keys";

  };

  config = lib.mkIf cfg.enable {

    apps.ai.opencode.enable = true;

  };
}
