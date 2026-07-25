{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
with lib.custom;

let
  cfg = config.services.redirect;

  mkRedirectService = name: rule: {
    name = "redirect-${name}";
    value = {
      description = "HTTP 302 redirect: /${name} -> ${rule.target}";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = pkgs.writeScript "redirect-${name}" ''
          #!${pkgs.python3}/bin/python3
          from http.server import HTTPServer, BaseHTTPRequestHandler
          class H(BaseHTTPRequestHandler):
              def do_GET(self):
                  self.send_response(302)
                  self.send_header("Location", "${rule.target}")
                  self.end_headers()
          HTTPServer(("127.0.0.1", ${toString rule.port}), H).serve_forever()
        '';
      };
    };
  };

in
{
  options.services.redirect = with types; {
    enable = mkBoolOpt false ''
      Enable HTTP 302 redirect services for Tailscale Serve path routing.
      Each rule creates a tiny HTTP server on localhost that returns a 302
      redirect to the target URL. Tailscale Serve proxies path requests
      to these servers, which bounce the browser to the direct port.
    '';

    rules = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          port = mkOption {
            type = types.int;
            description = "Localhost port to listen on (tailscale serve targets this)";
          };
          target = mkOption {
            type = types.str;
            description = "URL to redirect the browser to (e.g. https://terra.tail9a2d08.ts.net:9090)";
          };
        };
      });
      default = { };
      description = "Redirect rules: name -> { port, target }";
    };
  };

  config = mkIf cfg.enable {
    systemd.services = listToAttrs (mapAttrsToList mkRedirectService cfg.rules);
  };
}
