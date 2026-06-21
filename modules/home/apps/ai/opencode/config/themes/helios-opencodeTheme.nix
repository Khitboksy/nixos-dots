{ lib }:

with lib;
with lib.custom;

''
  {
    "$schema": "https://opencode.ai/theme.json",
    "name": "Helios",
    "defs": {
    "macAccent": "${colors.mauve.hex}",
    "macRosewater": "${colors.rosewater.hex}",
    "macFlamingo": "${colors.flamingo.hex}",
    "macPink": "${colors.pink.hex}",
    "macMauve": "${colors.mauve.hex}",
    "macRed": "${colors.red.hex}",
    "macMaroon": "${colors.maroon.hex}",
    "macPeach": "${colors.peach.hex}",
    "macYellow": "${colors.yellow.hex}",
    "macGreen": "${colors.green.hex}",
    "macTeal": "${colors.teal.hex}",
    "macSky": "${colors.sky.hex}",
    "macSapphire": "${colors.sapphire.hex}",
    "macBlue": "${colors.blue.hex}",
    "macLavender": "${colors.lavender.hex}",
    "macText": "${colors.text.hex}",
    "macSubtext1": "${colors.subtext1.hex}",
    "macSubtext0": "${colors.subtext0.hex}",
    "macOverlay2": "${colors.overlay2.hex}",
    "macOverlay1": "${colors.overlay1.hex}",
    "macOverlay0": "${colors.overlay0.hex}",
    "macSurface2": "${colors.surface2.hex}",
    "macSurface1": "${colors.surface1.hex}",
    "macSurface0": "${colors.surface0.hex}",
    "macBase": "${colors.base.hex}",
    "macMantle": "${colors.mantle.hex}",
    "macCrust": "${colors.crust.hex}"
    },
    "theme": {
      "primary": {
        "dark": "macAccent",
        "light": "macAccent"
      },
      "secondary": {
        "dark": "macAccent",
        "light": "macAccent"
      },
      "accent": {
        "dark": "macPink",
        "light": "macPink"
      },
      "text": {
        "dark": "macText",
        "light": "macText"
      },
      "textMuted": {
        "dark": "macSubtext1",
        "light": "macSubtext1"
      },
      "background": {
        "dark": "transparent",
        "light": "transparent"
      },
      "error": {
        "dark": "macRed",
        "light": "macRed"
      },
      "warning": {
        "dark": "macYellow",
        "light": "macYellow"
      },
      "success": {
        "dark": "macGreen",
        "light": "macGreen"
      },
      "info": {
        "dark": "macTeal",
        "light": "macTeal"
      },
      "backgroundPanel": {
        "dark": "macMantle",
        "light": "macMantle"
      },
      "backgroundElement": {
        "dark": "macCrust",
        "light": "macCrust"
      },
      "border": {
        "dark": "macSurface0",
        "light": "macSurface0"
      },
      "borderActive": {
        "dark": "macSurface1",
        "light": "macSurface1"
      },
      "borderSubtle": {
        "dark": "macSurface2",
        "light": "macSurface2"
      },
      "diffAdded": {
        "dark": "macGreen",
        "light": "macGreen"
      },
      "diffRemoved": {
        "dark": "macRed",
        "light": "macRed"
      },
      "diffContext": {
       "dark": "macOverlay2",
       "light": "macOverlay2"
      },
      "diffHunkHeader": {
        "dark": "macPeach",
       "light": "macPeach"
      },
      "diffHighlightAdded": {
        "dark": "macGreen",
        "light": "macGreen"
      },
      "diffHighlightRemoved": {
        "dark": "macRed",
        "light": "macRed"
      },
      "diffAddedBg": {
        "dark": "#a6e3a180",
        "light": "#a6e3a180"
      },
      "diffRemovedBg": {
        "dark": "#f38ba880",
        "light": "#f38ba880"
      },
      "diffContextBg": {
        "dark": "macMantle",
        "light": "macMantle"
      },
      "diffLineNumber": {
        "dark": "macSurface1",
        "light": "macSurface1"
      },
      "diffAddedLineNumberBg": {
        "dark": "#a6e3a140",
        "light": "#a6e3a140"
      },
      "diffRemovedLineNumberBg": {
        "dark": "#f38ba840",
        "light": "#f38ba840"
      },
      "markdownText": {
        "dark": "macText",
        "light": "macText"
      },
      "markdownHeading": {
        "dark": "macAccent",
        "light": "macAccent"
      },
      "markdownLink": {
        "dark": "macBlue",
        "light": "macBlue"
      },
      "markdownLinkText": {
        "dark": "macSky",
        "light": "macSky"
      },
      "markdownCode": {
        "dark": "macGreen",
        "light": "macGreen"
      },
      "markdownBlockQuote": {
        "dark": "macYellow",
        "light": "macYellow"
      },
      "markdownEmph": {
        "dark": "macYellow",
        "light": "macYellow"
      },
      "markdownStrong": {
        "dark": "macPeach",
        "light": "macPeach"
      },
      "markdownHorizontalRule": {
        "dark": "macSubtext0",
        "light": "macSubtext0"
      },
      "markdownListItem": {
        "dark": "macBlue",
        "light": "macBlue"
      },
      "markdownListEnumeration": {
        "dark": "macSky",
        "light": "macSky"
      },
      "markdownImage": {
        "dark": "macBlue",
        "light": "macBlue"
      },
      "markdownImageText": {
        "dark": "macSky",
        "light": "macSky"
      },
      "markdownCodeBlock": {
        "dark": "macText",
        "light": "macText"
      },
      "syntaxComment": {
        "dark": "macOverlay2",
        "light": "macOverlay2"
      },
      "syntaxKeyword": {
        "dark": "macAccent",
        "light": "macAccent"
      },
      "syntaxFunction": {
        "dark": "macBlue",
        "light": "macBlue"
      },
      "syntaxVariable": {
        "dark": "macRed",
        "light": "macRed"
      },
      "syntaxString": {
        "dark": "macGreen",
        "light": "macGreen"
      },
      "syntaxNumber": {
        "dark": "macPeach",
        "light": "macPeach"
      },
      "syntaxType": {
        "dark": "macYellow",
        "light": "macYellow"
      },
      "syntaxOperator": {
        "dark": "macSky",
        "light": "macSky"
      },
      "syntaxPunctuation": {
        "dark": "macText",
        "light": "macText"
      }
    }  
  }
''
