{
  lib,
  buildGoModule,
}:

buildGoModule {
  pname = "danklrc";
  version = "0.1.0";

  src = ./.;

  vendorHash = "sha256-A3x9UHZoqJs33oN5hJJesKDjr6ApYWy5o6IrmHr543w=";

  meta = {
    description = "Multi-provider lyrics fetcher wrapping AvengeMedia/dankgo/lyrics for rmpc";
    mainProgram = "danklrc";
  };
}
