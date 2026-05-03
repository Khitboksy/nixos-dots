{ lib }:

with lib;
with lib.custom;

''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>name</key>
    <string>Helios Catppuccin Mocha</string>
    <key>semanticClass</key>
    <string>theme.dark.helios-mocha</string>
    <key>uuid</key>
    <string>helios-mocha-00000000-0000-0000-0000-000000000000</string>
    <key>author</key>
    <string>Helios</string>
    <key>colorSpaceName</key>
    <string>sRGB</string>
    <key>settings</key>
    <array>
      <dict>
        <key>settings</key>
        <dict>
          <key>background</key>
          <string>${colors.base.hex}</string>
          <key>foreground</key>
          <string>${colors.text.hex}</string>
          <key>caret</key>
          <string>${colors.rosewater.hex}</string>
          <key>lineHighlight</key>
          <string>${colors.surface0.hex}</string>
          <key>misspelling</key>
          <string>${colors.red.hex}</string>
          <key>accent</key>
          <string>${colors.mauve.hex}</string>
          <key>selection</key>
          <string>${colors.overlay2.hex}40</string>
          <key>activeGuide</key>
          <string>${colors.surface1.hex}</string>
          <key>findHighlight</key>
          <string>${colors.surface2.hex}</string>
          <key>gutterForeground</key>
          <string>${colors.overlay1.hex}</string>
        </dict>
      </dict>
      <dict>
        <key>name</key>
        <string>Basic text</string>
        <key>scope</key>
        <string>text, source</string>
        <key>settings</key>
        <dict>
          <key>foreground</key>
          <string>${colors.text.hex}</string>
        </dict>
      </dict>
      <dict>
        <key>name</key>
        <string>Comments</string>
        <key>scope</key>
        <string>comment, punctuation.definition.comment</string>
        <key>settings</key>
        <dict>
          <key>foreground</key>
          <string>${colors.overlay2.hex}</string>
          <key>fontStyle</key>
          <string>italic</string>
        </dict>
      </dict>
      <dict>
        <key>scope</key>
        <string>string, punctuation.definition.string</string>
        <key>settings</key>
        <dict>
          <key>foreground</key>
          <string>${colors.green.hex}</string>
        </dict>
      </dict>
      <dict>
        <key>scope</key>
        <string>constant.character.escape</string>
        <key>settings</key>
        <dict>
          <key>foreground</key>
          <string>${colors.pink.hex}</string>
        </dict>
      </dict>
      <dict>
        <key>name</key>
        <string>Numbers</string>
        <key>scope</key>
        <string>constant.numeric</string>
        <key>settings</key>
        <dict>
          <key>foreground</key>
          <string>${colors.peach.hex}</string>
        </dict>
      </dict>
      <dict>
        <key>scope</key>
        <string>keyword, keyword.operator, storage.type, storage.modifier</string>
        <key>settings</key>
        <dict>
          <key>foreground</key>
          <string>${colors.mauve.hex}</string>
        </dict>
      </dict>
      <dict>
        <key>scope</key>
        <string>entity.name.function, support.function, variable.function</string>
        <key>settings</key>
        <dict>
          <key>foreground</key>
          <string>${colors.blue.hex}</string>
          <key>fontStyle</key>
          <string>italic</string>
        </dict>
      </dict>
      <dict>
        <key>name</key>
        <string>Classes</string>
        <key>scope</key>
        <string>entity.name.class, entity.other.inherited-class, support.class</string>
        <key>settings</key>
        <dict>
          <key>foreground</key>
          <string>${colors.yellow.hex}</string>
          <key>fontStyle</key>
          <string>italic</string>
        </dict>
      </dict>
      <dict>
        <key>name</key>
        <string>Types</string>
        <key>scope</key>
        <string>meta.type, support.type, entity.name.type</string>
        <key>settings</key>
        <dict>
          <key>foreground</key>
          <string>${colors.yellow.hex}</string>
          <key>fontStyle</key>
          <string>italic</string>
        </dict>
      </dict>
      <dict>
        <key>name</key>
        <string>Variables</string>
        <key>scope</key>
        <string>variable.other, variable.parameter</string>
        <key>settings</key>
        <dict>
          <key>foreground</key>
          <string>${colors.text.hex}</string>
        </dict>
      </dict>
      <dict>
        <key>name</key>
        <string>Function parameters</string>
        <key>scope</key>
        <string>variable.parameter, meta.function.parameters</string>
        <key>settings</key>
        <dict>
          <key>foreground</key>
          <string>${colors.maroon.hex}</string>
          <key>fontStyle</key>
          <string>italic</string>
        </dict>
      </dict>
      <dict>
        <key>name</key>
        <string>Built-ins</string>
        <key>scope</key>
        <string>constant.language, support.function.builtin</string>
        <key>settings</key>
        <dict>
          <key>foreground</key>
          <string>${colors.red.hex}</string>
        </dict>
      </dict>
      <dict>
        <key>scope</key>
        <string>punctuation</string>
        <key>settings</key>
        <dict>
          <key>foreground</key>
          <string>${colors.overlay2.hex}</string>
        </dict>
      </dict>
      <dict>
        <key>name</key>
        <string>Operators</string>
        <key>scope</key>
        <string>keyword.operator</string>
        <key>settings</key>
        <dict>
          <key>foreground</key>
          <string>${colors.teal.hex}</string>
        </dict>
      </dict>
      <dict>
        <key>name</key>
        <string>JSON/YAML keys</string>
        <key>scope</key>
        <string>support.type.property-name.json, support.type.property-name.yaml, entity.name.tag.yaml</string>
        <key>settings</key>
        <dict>
          <key>foreground</key>
          <string>${colors.blue.hex}</string>
        </dict>
      </dict>
      <dict>
        <key>name</key>
        <string>Markdown headings</string>
        <key>scope</key>
        <string>markup.heading</string>
        <key>settings</key>
        <dict>
          <key>foreground</key>
          <string>${colors.red.hex}</string>
          <key>fontStyle</key>
          <string>bold</string>
        </dict>
      </dict>
      <dict>
        <key>name</key>
        <string>Markdown bold</string>
        <key>scope</key>
        <string>markup.bold</string>
        <key>settings</key>
        <dict>
          <key>foreground</key>
          <string>${colors.red.hex}</string>
          <key>fontStyle</key>
          <string>bold</string>
        </dict>
      </dict>
      <dict>
        <key>name</key>
        <string>Markdown italic</string>
        <key>scope</key>
        <string>markup.italic</string>
        <key>settings</key>
        <dict>
          <key>foreground</key>
          <string>${colors.red.hex}</string>
          <key>fontStyle</key>
          <string>italic</string>
        </dict>
      </dict>
      <dict>
        <key>name</key>
        <string>Markdown links</string>
        <key>scope</key>
        <string> markup.link, string.other.link.title.markdown</string>
        <key>settings</key>
        <dict>
          <key>foreground</key>
          <string>${colors.blue.hex}</string>
        </dict>
      </dict>
      <dict>
        <key>name</key>
        <string>Markdown code</string>
        <key>scope</key>
        <string>markup.inline.raw.string.markdown, markup.raw.block.markdown</string>
        <key>settings</key>
        <dict>
          <key>foreground</key>
          <string>${colors.green.hex}</string>
        </dict>
      </dict>
      <dict>
        <key>name</key>
        <string>Diff inserted</string>
        <key>scope</key>
        <string>markup.inserted.diff</string>
        <key>settings</key>
        <dict>
          <key>foreground</key>
          <string>${colors.green.hex}</string>
        </dict>
      </dict>
      <dict>
        <key>name</key>
        <string>Diff deleted</string>
        <key>scope</key>
        <string>markup.deleted.diff</string>
        <key>settings</key>
        <dict>
          <key>foreground</key>
          <string>${colors.red.hex}</string>
        </dict>
      </dict>
      <dict>
        <key>name</key>
        <string>Diff header</string>
        <key>scope</key>
        <string>meta.diff.header.from-file, meta.diff.header.to-file</string>
        <key>settings</key>
        <dict>
          <key>foreground</key>
          <string>${colors.blue.hex}</string>
        </dict>
      </dict>
      <dict>
        <key>name</key>
        <string>HTML tags</string>
        <key>scope</key>
        <string>entity.name.tag</string>
        <key>settings</key>
        <dict>
          <key>foreground</key>
          <string>${colors.blue.hex}</string>
        </dict>
      </dict>
      <dict>
        <key>name</key>
        <string>HTML attributes</string>
        <key>scope</key>
        <string>entity.other.attribute-name</string>
        <key>settings</key>
        <dict>
          <key>foreground</key>
          <string>${colors.yellow.hex}</string>
        </dict>
      </dict>
      <dict>
        <key>name</key>
        <string>CSS properties</string>
        <key>scope</key>
        <string>support.type.property-name.css</string>
        <key>settings</key>
        <dict>
          <key>foreground</key>
          <string>${colors.blue.hex}</string>
        </dict>
      </dict>
      <dict>
        <key>name</key>
        <string>CSS values</string>
        <key>scope</key>
        <string>meta.property-value</string>
        <key>settings</key>
        <dict>
          <key>foreground</key>
          <string>${colors.green.hex}</string>
        </dict>
      </dict>
      <dict>
        <key>name</key>
        <string>Python decorators</string>
        <key>scope</key>
        <string>entity.name.function.decorator.python</string>
        <key>settings</key>
        <dict>
          <key>foreground</key>
          <string>${colors.peach.hex}</string>
          <key>fontStyle</key>
          <string>italic</string>
        </dict>
      </dict>
      <dict>
        <key>name</key>
        <string>Python self</string>
        <key>scope</key>
        <string>variable.language.special.self.python</string>
        <key>settings</key>
        <dict>
          <key>foreground</key>
          <string>${colors.red.hex}</string>
          <key>fontStyle</key>
          <string>italic</string>
        </dict>
      </dict>
      <dict>
        <key>name</key>
        <string>Rust attributes</string>
        <key>scope</key>
        <string>meta.attribute.rust</string>
        <key>settings</key>
        <dict>
          <key>foreground</key>
          <string>${colors.peach.hex}</string>
        </dict>
      </dict>
      <dict>
        <key>name</key>
        <string>Nix paths</string>
        <key>scope</key>
        <string>string.unquoted.path.nix</string>
        <key>settings</key>
        <dict>
          <key>foreground</key>
          <string>${colors.pink.hex}</string>
        </dict>
      </dict>
      <dict>
        <key>name</key>
        <string>Nix attribute names</string>
        <key>scope</key>
        <string>entity.other.attribute-name.multipart.nix</string>
        <key>settings</key>
        <dict>
          <key>foreground</key>
          <string>${colors.blue.hex}</string>
        </dict>
      </dict>
      <dict>
        <key>name</key>
        <string>Go functions</string>
        <key>scope</key>
        <string>entity.name.function.go</string>
        <key>settings</key>
        <dict>
          <key>foreground</key>
          <string>${colors.blue.hex}</string>
        </dict>
      </dict>
      <dict>
        <key>name</key>
        <string>Shell shebang</string>
        <key>scope</key>
        <string>meta.shebang</string>
        <key>settings</key>
        <dict>
          <key>foreground</key>
          <string>${colors.red.hex}</string>
        </dict>
      </dict>
    </array>
  </dict>
</plist>
''