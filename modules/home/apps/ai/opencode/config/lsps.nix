{
  pkgs,
  ...
}:

{

  lsp = {
    nil = {
      command = [ "${pkgs.nil}/bin/nil" ];
      extensions = [ ".nix" ];
    };

    typescript = {

      command = [
        "bunx"
        "--bun"
        "typescript-language-server"
        "--stdio"
      ];

      extensions = [
        ".ts"
        ".tsx"
        ".js"
        ".jsx"
        ".mts"
        ".cts"
        ".mjs"
        ".cjs"
      ];

      initialization.plugins = [
        {
          name = "@effect/language-service";
          enabled = true;
          # Strict Effect framework diagnostics

          diagnostics = {
            importFromBarrel = "error";
            unsafeEffectTypeAssertion = "error";
            instanceOfSchema = "error";
            missingEffectServiceDependency = "error";
            leakingRequirements = "error";
            globalErrorInEffectCatch = "error";
            globalErrorInEffectFailure = "error";
            cryptoRandomUUID = "error";
            nodeBuiltinImport = "error";
            globalDate = "error";
            globalConsole = "error";
            globalRandom = "error";
            globalTimers = "error";
          };

        }

      ];
    };
  };
}
