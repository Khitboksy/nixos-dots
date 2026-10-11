# Homestead Minecraft server -- version registry.
# Single source of truth for all pinned component versions.
# Consumed by default.nix (NixOS).
{
  mcVersion = "1.20.1";

  fabricLoader = {
    version = "0.18.4";
    stable = true;
  };

  fabricInstaller = {
    version = "1.0.1";
  };

  mods = {
    fabric-api = {
      projectId = "P7dR8mSH";
      version = "0.92.2+1.20.1";
      versionId = "P7uGFii0";
      source = "modrinth";
    };
    lithium = {
      projectId = "gvQqBUqZ";
      version = "0.11.3";
      versionId = "vuuAe7ZA";
      source = "modrinth";
    };
    ferritecore = {
      projectId = "uXXizFIs";
      version = "6.0.1";
      versionId = "unerR5MN";
      source = "modrinth";
    };
    krypton = {
      projectId = "fQEb0iXm";
      version = "0.2.3";
      versionId = "jiDwS0W1";
      source = "modrinth";
    };
    servercore = {
      projectId = "4WWQxlQP";
      version = "1.5.2+1.20.1";
      versionId = "m978FuzE";
      source = "modrinth";
    };
    modernfix = {
      projectId = "nmDcB62a";
      version = "5.19.5+mc1.20.1";
      versionId = "qIu7zOc4";
      source = "modrinth";
    };
    "alternate-current" = {
      projectId = "r0v8vy1s";
      version = "1.9.0";
      versionId = "ckuIQWvo";
      source = "modrinth";
    };
    server-waypoint = {
      projectId = "UyBaYBa7";
      version = "3.0.4";
      versionId = "qR0d5DR4";
      source = "modrinth";
    };
  };

  addons = {
    bluemap = {
      version = "3.20";
      source = "github";
      repo = "BlueMap-Minecraft/BlueMap";
      note = "Last version supporting 1.20.x; jar named BlueMap-3.20-fabric-1.20.jar";
    };
  };
}
