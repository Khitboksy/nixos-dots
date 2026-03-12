vec4 zoom_in(vec3 coords_geo, vec3 size_geo) {
                float progress = niri_clamped_progress;
                float scale = progress;
                vec2 coords = (coords_geo.xy - vec2(0.5, 0.5)) * size_geo.xy;
                coords = coords / scale;
                coords_geo = vec3(coords / size_geo.xy + vec2(0.5, 0.5), 1.0);
                vec3 coords_tex = niri_geo_to_tex * coords_geo;
                vec4 color = texture2D(niri_tex, coords_tex.st);
                color.a *= progress;

                return color;
              }
              vec4 open_color(vec3 coords_geo, vec3 size_geo) {
                return zoom_in(coords_geo, size_geo);
              }
