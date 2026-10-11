# Niri Minecraft server — version registry.
# Single source of truth for all pinned component versions.
# Consumed by default.nix (NixOS) and mc-modcheck (shell).
{
  mcVersion = "1.21.11";

  fabricLoader = {
    version = "0.19.3";
    stable = true;
  };

  fabricInstaller = {
    version = "1.0.1";
  };

  mods = {
    voicechat = {
      projectId = "9eGKb6K1";
      version = "2.6.22";
      source = "modrinth";
    };
    lithium = {
      projectId = "gvQqBUqZ";
      version = "0.21.3";
      source = "modrinth";
    };
    fabric-api = {
      projectId = "P7dR8mSH";
      version = "0.141.6+1.21.11";
      source = "modrinth";
    };
    floodgate = {
      projectId = "bWrNNfkb";
      version = "2.2.6-b60";
      source = "modrinth";
    };
    rei = {
      projectId = "nfn13YXA";
      version = "21.11.816";
      source = "modrinth";
    };
    architectury = {
      projectId = "lhGA9TYQ";
      version = "19.0.1";
      source = "modrinth";
    };
    cloth-config = {
      projectId = "9s6osm5g";
      version = "21.11.153";
      source = "modrinth";
    };
    jade = {
      projectId = "nvQzSEkH";
      version = "21.1.6";
      source = "modrinth";
    };
    appleskin = {
      projectId = "EsAfCjCV";
      version = "3.0.8";
      source = "modrinth";
    };
    ferritecore = {
      projectId = "uXXizFIs";
      version = "8.2.0";
      source = "modrinth";
    };
    server-waypoint = {
      projectId = "UyBaYBa7";
      version = "3.0.3";
      source = "modrinth";
    };
  };

  addons = {
    viaproxy = {
      version = "3.4.12";
      source = "github";
      repo = "ViaVersion/ViaProxy";
      note = "Check MC compatibility at viaversion.com";
    };
    geyser-viaproxy = {
      version = "2.11.2";
      source = "geyser-api";
    };
    bluemap = {
      version = "5.15";
      source = "github";
      repo = "BlueMap-Minecraft/BlueMap";
      note = "Check MC compatibility at bluemap.org";
    };
  };
}
