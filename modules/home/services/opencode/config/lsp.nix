{
  pkgs,
  ...
}:

{

  nixd = {
    command = [ "${pkgs.nixd}/bin/nixd" ];
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

    # Enable @effect/language-service plugin for Effect framework diagnostics
    initializationOptions.plugins = [
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

}
