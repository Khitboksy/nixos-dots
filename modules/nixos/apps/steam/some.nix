config = {
        enable = true;
        defaultCompatTool = "Proton-Experimental";
        closeSteam = true;
        apps = {
          deadlock = {
            id = 1422450;
            compatTool = "GE-Proton10-29";
            launchOptions = {
              env = {
                PROTON_USE_NTSYNC = true;
                #DXVK_ASYNC = "1";
              };
              args = [
                "-novid"
                "-nojoy"
                "-novsync"
                "+exec autoexec.cfg"
                "-no_prewarm_map"
              ];
              wrappers = [
                #"/home/helios/.local/bin/mangohud-def"
                (getExe pkgs.mangohud)
                "gamescope -r 165 -w 1366 -h 768 --force-grab-cursor --"
              ];
            };
          };
          overwatch = {
            id = 2357570;
            compatTool = "GE-Proton10-29";
            launchOptions = {
              env = {
                SDL_VIDEODRIVER = "x11";
                PROTON_USE_NTSYNC = true;
              };
              wrappers = [
                (getExe pkgs.gamemode)
                "gamescope -f -r 165 -w 1920 -h 1080 --force-grab-cursor --"
              ];
            };
          };
        };
      };

