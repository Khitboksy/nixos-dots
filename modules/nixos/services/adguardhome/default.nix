{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
with lib.custom;

let
  cfg = config.adguardhome;
in

{
  options.adguardhome = with types; {
    enable = mkBoolOpt false "Enable AdGuard Home (network-wide ad blocking DNS server)";

    port = mkOpt types.port 3000 "Port for the AdGuard Home web interface";

    mutableSettings = mkBoolOpt false ''
      Allow changes made on the AdGuard Home web interface to persist between
      service restarts. When true, declarative settings in this module serve
      as a baseline - changes made via the web UI survive reboots and are
      merged with (underneath) the declarative values. Set to false for
      fully-declarative (Nix-managed) configs.

      NOTE: Set to false initially to bootstrap the config file fresh.
      After the first successful start, change this to true if you want
      web UI changes to persist across rebuilds.
    '';
  };

  config = mkIf cfg.enable {
    services.adguardhome = {
      enable = true;
      host = "127.0.0.1";        # Web UI only accessible locally
      port = cfg.port;            # (use Tailscale Serve to expose it)
      mutableSettings = cfg.mutableSettings;

      settings = {
        schema_version = 34;

        dns = {
          # Listen on all interfaces for DNS - this is the service
          bind_host = "0.0.0.0";
          port = 53;

          # Upstream DNS via encrypted DoH
          upstream_dns = [
            "https://dns.cloudflare.com/dns-query"
            "https://dns.quad9.net/dns-query"
          ];

          fallback_dns = [
            "https://dns.cloudflare.com/dns-query"
            "1.1.1.1"
          ];

          # Bootstrap: used to resolve the DoH server hostnames themselves
          bootstrap_dns = [
            "1.1.1.1"
            "9.9.9.9"
          ];

          edns_client_subnet = {
            enabled = true;
            use_custom = false;
            custom_ip = "";
          };
          enable_dnssec = true;
          cache_size = 4194304;    # 4 MB DNS cache
        };

        filtering = {
          querylog_enabled = true;
          querylog_interval = 7776000;  # 90 days

          filtering_enabled = true;
          parental_enabled = false;
          blocked_response_ttl = 10;

          # Standard blocklists
          filters = [
            {
              enabled = true;
              url = "https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt";
              name = "AdGuard DNS filter";
              id = 1;
            }
            {
              enabled = true;
              url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
              name = "StevenBlack's Unified Hosts";
              id = 2;
            }
          ];

          whitelist_filters = [ ];
        };

        clients = {
          runtime_sources = {
            whois = true;
            arp = true;
            rdns = true;
            dhcp = true;
            hosts = true;
          };
          persistent = [ ];
        };

        # The schema_version >= 23 auto-injects http.address from host:port
        # but we also explicitly set bind_host/bind_port for DNS clarity
        http = {
          address = "127.0.0.1:${toString cfg.port}";
        };
      };
    };

    # Open DNS ports (53 UDP + TCP) so AdGuard Home can serve DNS
    networking.firewall = {
      allowedUDPPorts = [ 53 ];
      allowedTCPPorts = [ 53 ];
    };
  };
}