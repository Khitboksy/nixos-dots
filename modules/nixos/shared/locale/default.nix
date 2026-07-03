{
  lib,
  config,
  ...
}:
let
  cfg = config.shared.locale;
in

with lib;
with lib.custom;
{
  options.shared.locale = with types; {
    enable = mkBoolOpt false "shared locale settings";
    defaultLocale = mkStringOpt' "en_US.UTF-8";
  };
  config = mkIf cfg.enable {
    i18n.defaultLocale = cfg.defaultLocale;
    i18n.extraLocaleSettings = {
      LC_ADDRESS = cfg.defaultLocale;
      LC_IDENTIFICATION = cfg.defaultLocale;
      LC_MEASUREMENT = cfg.defaultLocale;
      LC_MONETARY = cfg.defaultLocale;
      LC_NAME = cfg.defaultLocale;
      LC_NUMERIC = cfg.defaultLocale;
      LC_PAPER = cfg.defaultLocale;
      LC_TELEPHONE = cfg.defaultLocale;
      LC_TIME = cfg.defaultLocale;
    };
  };
}
