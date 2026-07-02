{ barName }:
let
  bars = {
    "helios" = import ./bars/helios.nix;
    "terra" = import ./bars/terra.nix;
  };
in
{
  bar = {
    order = [ "main" ];
    main = bars.${barName};
  };
}
