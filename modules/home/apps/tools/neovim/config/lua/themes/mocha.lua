-- Catppuccin Mocha colorscheme for Neovim
-- Load with: colorscheme mocha
-- This is the main theme file with ALL configurations

local M = {}

function M.setup()
  -- Theme setup is done at the end of this file
end

-- Load colors from lib/theme (mirrors lib/theme/default.nix)
local colors = require("themes.colors")

-- Add none for transparent highlighting
colors.none = "NONE"

-- Helper functions
local function darken(col, amount, base)
  if col == "NONE" then return "NONE" end
  local r = tonumber(col:sub(2, 3), 16)
  local g = tonumber(col:sub(4, 5), 16)
  local b = tonumber(col:sub(6, 7), 16)
  local br = tonumber(base:sub(2, 3), 16)
  local bg = tonumber(base:sub(4, 5), 16)
  local bb = tonumber(base:sub(6, 7), 16)
  r = math.floor(r * (1 - amount) + br * amount)
  g = math.floor(g * (1 - amount) + bg * amount)
  b = math.floor(b * (1 - amount) + bb * amount)
  return string.format("#%02x%02x%02x",
    math.min(255, math.max(0, r)),
    math.min(255, math.max(0, g)),
    math.min(255, math.max(0, b))
  )
end

local function lighten(col, amount, base)
  if col == "NONE" then return "NONE" end
  return darken(col, -amount, base)
end

local function set_hl(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- ===========================================
-- Editor Highlights
-- ===========================================
local function setup_editor()
  set_hl("ColorColumn", { bg = "NONE" })
  set_hl("Conceal", { fg = colors.overlay1.hex })
  set_hl("Cursor", { fg = colors.base.hex, bg = colors.rosewater.hex })
  set_hl("lCursor", { fg = colors.base.hex, bg = colors.rosewater.hex })
  set_hl("CursorIM", { fg = colors.base.hex, bg = colors.rosewater.hex })
  set_hl("CursorColumn", { bg = "NONE" })
  set_hl("CursorLine", { bg = "NONE" })
  set_hl("Directory", { fg = colors.blue.hex })
  set_hl("EndOfBuffer", { fg = colors.surface1.hex })
  set_hl("ErrorMsg", { fg = colors.red.hex, bold = true, italic = true })
  set_hl("VertSplit", { fg = colors.crust.hex })
  set_hl("Folded", { fg = colors.blue.hex, bg = "NONE" })
  set_hl("FoldColumn", { fg = colors.overlay0.hex })
  set_hl("SignColumn", { fg = colors.surface1.hex, bg = "NONE" })
  set_hl("SignColumnSB", { bg = "NONE", fg = colors.surface1.hex })
  set_hl("LineNr", { fg = colors.surface1.hex })
  set_hl("CursorLineNr", { fg = colors.lavender.hex })
  set_hl("MatchParen", { fg = colors.peach.hex, bg = darken(colors.surface1.hex, 0.70, colors.base.hex), bold = true })
  set_hl("ModeMsg", { fg = colors.green.hex, bold = true })
  set_hl("MoreMsg", { fg = colors.blue.hex })
  set_hl("NonText", { fg = colors.overlay0.hex })
  set_hl("Normal", { fg = colors.text.hex })
  set_hl("NormalNC", { fg = colors.text.hex })
  set_hl("NormalSB", { fg = colors.text.hex })
  set_hl("NormalFloat", { fg = colors.text.hex })
  set_hl("FloatBorder", { fg = colors.blue.hex, bg = "NONE" })
  set_hl("FloatTitle", { fg = colors.subtext0.hex, bg = "NONE" })
  set_hl("FloatShadow", { bg = "NONE" })
  set_hl("Pmenu", { bg = "NONE", fg = colors.overlay2.hex })
  set_hl("PmenuSel", { bg = "NONE", bold = true })
  set_hl("PmenuMatch", { fg = colors.text.hex, bold = true })
  set_hl("PmenuSbar", { bg = "NONE" })
  set_hl("PmenuThumb", { bg = colors.overlay0.hex })
  set_hl("Question", { fg = colors.blue.hex })
  set_hl("QuickFixLine", { bg = darken(colors.surface1.hex, 0.70, colors.base.hex), bold = true })
  set_hl("Search", { bg = darken(colors.sky.hex, 0.30, colors.base.hex), fg = colors.text.hex })
  set_hl("IncSearch", { bg = darken(colors.sky.hex, 0.90, colors.base.hex), fg = colors.mantle.hex })
  set_hl("CurSearch", { bg = colors.red.hex, fg = colors.mantle.hex })
  set_hl("SpellBad", { sp = colors.red.hex, undercurl = true })
  set_hl("SpellCap", { sp = colors.yellow.hex, undercurl = true })
  set_hl("SpellLocal", { sp = colors.blue.hex, undercurl = true })
  set_hl("SpellRare", { sp = colors.green.hex, undercurl = true })
  set_hl("StatusLine", { fg = colors.text.hex, bg = "NONE" })
  set_hl("StatusLineNC", { fg = colors.surface1.hex, bg = "NONE" })
  set_hl("TabLine", { bg = "NONE", fg = colors.overlay0.hex })
  set_hl("TabLineFill", { bg = "NONE" })
  set_hl("TabLineSel", { link = "Normal" })
  set_hl("TermCursor", { fg = colors.base.hex, bg = colors.rosewater.hex })
  set_hl("TermCursorNC", { fg = colors.base.hex, bg = colors.overlay2.hex })
  set_hl("Title", { fg = colors.blue.hex, bold = true })
  set_hl("Visual", { fg = colors.blue.hex, bg = "NONE", bold = true })
  set_hl("VisualNOS", { bg = "NONE", bold = true })
  set_hl("WarningMsg", { fg = colors.yellow.hex })
  set_hl("Whitespace", { fg = colors.surface1.hex })
  set_hl("WildMenu", { bg = colors.overlay0.hex })
  set_hl("WinBar", { fg = colors.rosewater.hex })
  set_hl("WinBarNC", { link = "WinBar" })
  set_hl("WinSeparator", { fg = colors.crust.hex })
end

-- ===========================================
-- Syntax Highlights
-- ===========================================
local function setup_syntax()
  set_hl("Comment", { fg = colors.overlay2.hex, italic = true })
  set_hl("Constant", { fg = colors.peach.hex })
  set_hl("String", { fg = colors.green.hex })
  set_hl("Character", { fg = colors.teal.hex })
  set_hl("Number", { fg = colors.peach.hex })
  set_hl("Boolean", { fg = colors.peach.hex })
  set_hl("Identifier", { fg = colors.flamingo.hex })
  set_hl("Function", { fg = colors.blue.hex })
  set_hl("Statement", { fg = colors.mauve.hex })
  set_hl("Conditional", { fg = colors.mauve.hex, italic = true })
  set_hl("Repeat", { fg = colors.mauve.hex })
  set_hl("Label", { fg = colors.sapphire.hex })
  set_hl("Operator", { fg = colors.sky.hex })
  set_hl("Keyword", { fg = colors.mauve.hex })
  set_hl("Exception", { fg = colors.mauve.hex })
  set_hl("PreProc", { fg = colors.pink.hex })
  set_hl("Include", { fg = colors.mauve.hex })
  set_hl("Macro", { fg = colors.mauve.hex })
  set_hl("StorageClass", { fg = colors.yellow.hex })
  set_hl("Structure", { fg = colors.yellow.hex })
  set_hl("Special", { fg = colors.pink.hex })
  set_hl("Type", { fg = colors.yellow.hex })
  set_hl("Typedef", { link = "Type" })
  set_hl("Tag", { fg = colors.lavender.hex, bold = true })
  set_hl("Delimiter", { fg = colors.overlay2.hex })
  set_hl("Underlined", { underline = true })
  set_hl("Bold", { bold = true })
  set_hl("Italic", { italic = true })
  set_hl("Error", { fg = colors.red.hex })
  set_hl("Todo", { bg = colors.flamingo.hex, fg = colors.base.hex, bold = true })
  set_hl("Added", { fg = colors.green.hex })
  set_hl("Changed", { fg = colors.blue.hex })
  set_hl("diffAdded", { fg = colors.green.hex })
  set_hl("diffRemoved", { fg = colors.red.hex })
  set_hl("diffChanged", { fg = colors.blue.hex })
  set_hl("DiffAdd", { bg = darken(colors.green.hex, 0.18, colors.base.hex) })
  set_hl("DiffChange", { bg = darken(colors.blue.hex, 0.07, colors.base.hex) })
  set_hl("DiffDelete", { bg = darken(colors.red.hex, 0.18, colors.base.hex) })
  set_hl("DiffText", { bg = darken(colors.blue.hex, 0.30, colors.base.hex) })
  set_hl("healthError", { fg = colors.red.hex })
  set_hl("healthSuccess", { fg = colors.teal.hex })
  set_hl("healthWarning", { fg = colors.yellow.hex })

  -- Markdown specific
  set_hl("markdownHeadingDelimiter", { fg = colors.peach.hex, bold = true })
  set_hl("markdownCode", { fg = colors.flamingo.hex })
  set_hl("markdownCodeBlock", { fg = colors.flamingo.hex })
  set_hl("markdownLinkText", { fg = colors.blue.hex, underline = true })
  set_hl("markdownH1", { link = "rainbow1" })
  set_hl("markdownH2", { link = "rainbow2" })
  set_hl("markdownH3", { link = "rainbow3" })
  set_hl("markdownH4", { link = "rainbow4" })
  set_hl("markdownH5", { link = "rainbow5" })
  set_hl("markdownH6", { link = "rainbow6" })
  set_hl("mkdCodeDelimiter", { bg = "NONE", fg = colors.text.hex })
  set_hl("mkdCodeStart", { fg = colors.flamingo.hex, bold = true })
  set_hl("mkdCodeEnd", { fg = colors.flamingo.hex, bold = true })

  -- Rainbow
  set_hl("rainbow1", { fg = colors.red.hex })
  set_hl("rainbow2", { fg = colors.peach.hex })
  set_hl("rainbow3", { fg = colors.yellow.hex })
  set_hl("rainbow4", { fg = colors.green.hex })
  set_hl("rainbow5", { fg = colors.sapphire.hex })
  set_hl("rainbow6", { fg = colors.lavender.hex })
end

-- ===========================================
-- Treesitter Highlights
-- ===========================================
local function setup_treesitter()
  -- Identifiers
  set_hl("@variable", { fg = colors.text.hex })
  set_hl("@variable.builtin", { fg = colors.red.hex })
  set_hl("@variable.parameter", { fg = colors.maroon.hex })
  set_hl("@variable.member", { fg = colors.lavender.hex })

  -- Constants
  set_hl("@constant", { link = "Constant" })
  set_hl("@constant.builtin", { fg = colors.peach.hex })
  set_hl("@constant.macro", { link = "Macro" })

  -- Modules
  set_hl("@module", { fg = colors.yellow.hex, italic = true })
  set_hl("@label", { link = "Label" })

  -- Strings
  set_hl("@string", { link = "String" })
  set_hl("@string.documentation", { fg = colors.teal.hex })
  set_hl("@string.regexp", { fg = colors.pink.hex })
  set_hl("@string.escape", { fg = colors.pink.hex })
  set_hl("@string.special", { link = "Special" })
  set_hl("@string.special.path", { link = "Special" })
  set_hl("@string.special.symbol", { fg = colors.flamingo.hex })
  set_hl("@string.special.url", { fg = colors.blue.hex, italic = true, underline = true })

  -- Characters
  set_hl("@character", { link = "Character" })
  set_hl("@character.special", { link = "SpecialChar" })

  -- Booleans & Numbers
  set_hl("@boolean", { link = "Boolean" })
  set_hl("@number", { link = "Number" })
  set_hl("@number.float", { link = "Float" })

  -- Types
  set_hl("@type", { link = "Type" })
  set_hl("@type.builtin", { fg = colors.mauve.hex })
  set_hl("@type.definition", { link = "Type" })

  -- Properties
  set_hl("@attribute", { link = "Constant" })
  set_hl("@property", { fg = colors.lavender.hex })

  -- Functions
  set_hl("@function", { link = "Function" })
  set_hl("@function.builtin", { fg = colors.peach.hex })
  set_hl("@function.call", { link = "Function" })
  set_hl("@function.macro", { fg = colors.pink.hex })
  set_hl("@function.method", { link = "Function" })
  set_hl("@function.method.call", { link = "Function" })
  set_hl("@constructor", { fg = colors.yellow.hex })

  -- Operators
  set_hl("@operator", { link = "Operator" })

  -- Keywords
  set_hl("@keyword", { link = "Keyword" })
  set_hl("@keyword.modifier", { link = "Keyword" })
  set_hl("@keyword.type", { link = "Keyword" })
  set_hl("@keyword.coroutine", { link = "Keyword" })
  set_hl("@keyword.function", { fg = colors.mauve.hex })
  set_hl("@keyword.operator", { fg = colors.mauve.hex })
  set_hl("@keyword.import", { link = "Include" })
  set_hl("@keyword.repeat", { link = "Repeat" })
  set_hl("@keyword.return", { fg = colors.mauve.hex })
  set_hl("@keyword.debug", { link = "Exception" })
  set_hl("@keyword.exception", { link = "Exception" })
  set_hl("@keyword.conditional", { link = "Conditional" })
  set_hl("@keyword.conditional.ternary", { link = "Operator" })
  set_hl("@keyword.directive", { link = "PreProc" })
  set_hl("@keyword.directive.define", { link = "Define" })

  -- Punctuation
  set_hl("@punctuation.delimiter", { link = "Delimiter" })
  set_hl("@punctuation.bracket", { fg = colors.overlay2.hex })
  set_hl("@punctuation.special", { link = "Special" })

  -- Comments
  set_hl("@comment", { link = "Comment" })
  set_hl("@comment.documentation", { link = "Comment" })
  set_hl("@comment.error", { fg = colors.base.hex, bg = colors.red.hex })
  set_hl("@comment.warning", { fg = colors.base.hex, bg = colors.yellow.hex })
  set_hl("@comment.hint", { fg = colors.base.hex, bg = colors.blue.hex })
  set_hl("@comment.todo", { fg = colors.base.hex, bg = colors.flamingo.hex })
  set_hl("@comment.note", { fg = colors.base.hex, bg = colors.rosewater.hex })

  -- Markup
  set_hl("@markup", { fg = colors.text.hex })
  set_hl("@markup.strong", { fg = colors.red.hex, bold = true })
  set_hl("@markup.italic", { fg = colors.red.hex, italic = true })
  set_hl("@markup.strikethrough", { fg = colors.text.hex, strikethrough = true })
  set_hl("@markup.underline", { link = "Underlined" })
  set_hl("@markup.heading", { fg = colors.blue.hex })
  set_hl("@markup.heading.markdown", { bold = true })
  set_hl("@markup.math", { fg = colors.blue.hex })
  set_hl("@markup.quote", { fg = colors.pink.hex })
  set_hl("@markup.environment", { fg = colors.pink.hex })
  set_hl("@markup.environment.name", { fg = colors.blue.hex })
  set_hl("@markup.link", { fg = colors.lavender.hex })
  set_hl("@markup.link.label", { fg = colors.lavender.hex })
  set_hl("@markup.link.url", { fg = colors.blue.hex, italic = true, underline = true })
  set_hl("@markup.raw", { fg = colors.green.hex })
  set_hl("@markup.list", { fg = colors.teal.hex })
  set_hl("@markup.list.checked", { fg = colors.green.hex })
  set_hl("@markup.list.unchecked", { fg = colors.overlay1.hex })

  -- Diff
  set_hl("@diff.plus", { link = "diffAdded" })
  set_hl("@diff.minus", { link = "diffRemoved" })
  set_hl("@diff.delta", { link = "diffChanged" })

  -- Tags
  set_hl("@tag", { fg = colors.blue.hex })
  set_hl("@tag.builtin", { fg = colors.blue.hex })
  set_hl("@tag.attribute", { fg = colors.yellow.hex, italic = true })
  set_hl("@tag.delimiter", { fg = colors.teal.hex })

  -- Legacy/aliases
  set_hl("@parameter", { fg = colors.maroon.hex })
  set_hl("@field", { fg = colors.lavender.hex })
  set_hl("@namespace", { fg = colors.yellow.hex })
  set_hl("@float", { link = "Float" })
  set_hl("@symbol", { fg = colors.flamingo.hex })
  set_hl("@text", { fg = colors.text.hex })
  set_hl("@text.strong", { fg = colors.red.hex, bold = true })
  set_hl("@text.emphasis", { fg = colors.red.hex, italic = true })
  set_hl("@text.underline", { link = "Underlined" })
  set_hl("@text.strike", { fg = colors.text.hex, strikethrough = true })
  set_hl("@text.uri", { fg = colors.blue.hex, italic = true, underline = true })
  set_hl("@text.title", { fg = colors.blue.hex })
  set_hl("@text.literal", { fg = colors.green.hex })
  set_hl("@text.reference", { fg = colors.lavender.hex })
  set_hl("@text.todo", { fg = colors.base.hex, bg = colors.flamingo.hex, bold = true })
  set_hl("@text.todo.checked", { fg = colors.green.hex })
  set_hl("@text.todo.unchecked", { fg = colors.overlay1.hex })
  set_hl("@text.warning", { fg = colors.base.hex, bg = colors.yellow.hex })
  set_hl("@text.note", { fg = colors.base.hex, bg = colors.blue.hex })
  set_hl("@text.danger", { fg = colors.base.hex, bg = colors.red.hex })
  set_hl("@method", { link = "Function" })
  set_hl("@method.call", { link = "Function" })
end

-- ===========================================
-- LSP Highlights
-- ===========================================
local function setup_lsp()
  set_hl("LspReferenceText", { bg = "NONE" })
  set_hl("LspReferenceRead", { bg = "NONE" })
  set_hl("LspReferenceWrite", { bg = "NONE" })
  set_hl("DiagnosticVirtualTextError", { bg = darken(colors.red.hex, 0.095, colors.base.hex), fg = colors.red.hex })
  set_hl("DiagnosticVirtualTextWarn", { bg = darken(colors.yellow.hex, 0.095, colors.base.hex), fg = colors.yellow.hex })
  set_hl("DiagnosticVirtualTextInfo", { bg = darken(colors.sky.hex, 0.095, colors.base.hex), fg = colors.sky.hex })
  set_hl("DiagnosticVirtualTextHint", { bg = darken(colors.teal.hex, 0.095, colors.base.hex), fg = colors.teal.hex })
  set_hl("DiagnosticError", { fg = colors.red.hex })
  set_hl("DiagnosticWarn", { fg = colors.yellow.hex })
  set_hl("DiagnosticInfo", { fg = colors.sky.hex })
  set_hl("DiagnosticHint", { fg = colors.teal.hex })
  set_hl("DiagnosticUnderlineError", { undercurl = true, sp = colors.red.hex })
  set_hl("DiagnosticUnderlineWarn", { undercurl = true, sp = colors.yellow.hex })
  set_hl("DiagnosticUnderlineInfo", { undercurl = true, sp = colors.sky.hex })
  set_hl("DiagnosticUnderlineHint", { undercurl = true, sp = colors.teal.hex })
  set_hl("DiagnosticFloatingError", { fg = colors.red.hex })
  set_hl("DiagnosticFloatingWarn", { fg = colors.yellow.hex })
  set_hl("DiagnosticFloatingInfo", { fg = colors.sky.hex })
  set_hl("DiagnosticFloatingHint", { fg = colors.teal.hex })
  set_hl("DiagnosticSignError", { fg = colors.red.hex })
  set_hl("DiagnosticSignWarn", { fg = colors.yellow.hex })
  set_hl("DiagnosticSignInfo", { fg = colors.sky.hex })
  set_hl("DiagnosticSignHint", { fg = colors.teal.hex })
  set_hl("LspDiagnosticsDefaultError", { fg = colors.red.hex })
  set_hl("LspDiagnosticsDefaultWarning", { fg = colors.yellow.hex })
  set_hl("LspDiagnosticsDefaultInformation", { fg = colors.sky.hex })
  set_hl("LspDiagnosticsDefaultHint", { fg = colors.teal.hex })
  set_hl("LspSignatureActiveParameter", { bg = "NONE", bold = true })
  set_hl("LspCodeLens", { fg = colors.overlay0.hex })
end

-- ===========================================
-- Neo-tree Integration
-- ===========================================
local function setup_neotree()
  set_hl("NeoTreeDirectoryName", { fg = colors.blue.hex })
  set_hl("NeoTreeDirectoryIcon", { fg = colors.blue.hex })
  set_hl("NeoTreeNormal", { fg = colors.text.hex, bg = "NONE" })
  set_hl("NeoTreeNormalNC", { fg = colors.text.hex, bg = "NONE" })
  set_hl("NeoTreeExpander", { fg = colors.overlay0.hex })
  set_hl("NeoTreeIndentMarker", { fg = colors.overlay0.hex })
  set_hl("NeoTreeRootName", { fg = colors.blue.hex, bold = true })
  set_hl("NeoTreeSymbolicLinkTarget", { fg = colors.pink.hex })
  set_hl("NeoTreeModified", { fg = colors.peach.hex })

  set_hl("NeoTreeGitAdded", { fg = colors.green.hex })
  set_hl("NeoTreeGitConflict", { fg = colors.red.hex })
  set_hl("NeoTreeGitDeleted", { fg = colors.red.hex })
  set_hl("NeoTreeGitIgnored", { fg = colors.overlay0.hex })
  set_hl("NeoTreeGitModified", { fg = colors.yellow.hex })
  set_hl("NeoTreeGitUnstaged", { fg = colors.red.hex })
  set_hl("NeoTreeGitUntracked", { fg = colors.mauve.hex })
  set_hl("NeoTreeGitStaged", { fg = colors.green.hex })

  set_hl("NeoTreeFloatBorder", { link = "FloatBorder" })
  set_hl("NeoTreeFloatTitle", { link = "FloatTitle" })
  set_hl("NeoTreeTitleBar", { fg = colors.mantle.hex, bg = colors.blue.hex })

  set_hl("NeoTreeFileNameOpened", { fg = colors.pink.hex })
  set_hl("NeoTreeDimText", { fg = colors.overlay1.hex })
  set_hl("NeoTreeFilterTerm", { fg = colors.green.hex, bold = true })
  set_hl("NeoTreeTabActive", { bg = "NONE", fg = colors.lavender.hex, bold = true })
  set_hl("NeoTreeTabInactive", { bg = "NONE", fg = colors.overlay0.hex })
  set_hl("NeoTreeTabSeparatorActive", { fg = colors.mantle.hex, bg = "NONE" })
  set_hl("NeoTreeTabSeparatorInactive", { fg = colors.base.hex, bg = "NONE" })
  set_hl("NeoTreeVertSplit", { fg = colors.base.hex, bg = "NONE" })
  set_hl("NeoTreeWinSeparator", { fg = colors.base.hex, bg = "NONE" })
  set_hl("NeoTreeStatusLineNC", { fg = colors.mantle.hex, bg = colors.mantle.hex })
end

-- ===========================================
-- Blink CMP Integration
-- ===========================================
local function setup_blink_cmp()
  set_hl("BlinkCmpLabel", { fg = colors.overlay2.hex })
  set_hl("BlinkCmpLabelDeprecated", { fg = colors.overlay0.hex, strikethrough = true })
  set_hl("BlinkCmpKind", { fg = colors.blue.hex })
  set_hl("BlinkCmpMenu", { link = "Pmenu" })
  set_hl("BlinkCmpDoc", { link = "NormalFloat" })
  set_hl("BlinkCmpLabelMatch", { link = "PmenuMatch" })
  set_hl("BlinkCmpMenuSelection", { bg = "NONE", bold = true })
  set_hl("BlinkCmpScrollBarGutter", { bg = "NONE" })
  set_hl("BlinkCmpScrollBarThumb", { bg = colors.overlay0.hex })
  set_hl("BlinkCmpLabelDescription", { link = "PmenuExtra" })
  set_hl("BlinkCmpLabelDetail", { link = "PmenuExtra" })
  set_hl("BlinkCmpSignatureHelpBorder", { link = "FloatBorder" })

  set_hl("BlinkCmpKindText", { fg = colors.green.hex })
  set_hl("BlinkCmpKindMethod", { fg = colors.blue.hex })
  set_hl("BlinkCmpKindFunction", { fg = colors.blue.hex })
  set_hl("BlinkCmpKindConstructor", { fg = colors.blue.hex })
  set_hl("BlinkCmpKindField", { fg = colors.green.hex })
  set_hl("BlinkCmpKindVariable", { fg = colors.flamingo.hex })
  set_hl("BlinkCmpKindClass", { fg = colors.yellow.hex })
  set_hl("BlinkCmpKindInterface", { fg = colors.yellow.hex })
  set_hl("BlinkCmpKindModule", { fg = colors.blue.hex })
  set_hl("BlinkCmpKindProperty", { fg = colors.blue.hex })
  set_hl("BlinkCmpKindUnit", { fg = colors.green.hex })
  set_hl("BlinkCmpKindValue", { fg = colors.peach.hex })
  set_hl("BlinkCmpKindEnum", { fg = colors.yellow.hex })
  set_hl("BlinkCmpKindKeyword", { fg = colors.mauve.hex })
  set_hl("BlinkCmpKindSnippet", { fg = colors.flamingo.hex })
  set_hl("BlinkCmpKindColor", { fg = colors.red.hex })
  set_hl("BlinkCmpKindFile", { fg = colors.blue.hex })
  set_hl("BlinkCmpKindReference", { fg = colors.red.hex })
  set_hl("BlinkCmpKindFolder", { fg = colors.blue.hex })
  set_hl("BlinkCmpKindEnumMember", { fg = colors.teal.hex })
  set_hl("BlinkCmpKindConstant", { fg = colors.peach.hex })
  set_hl("BlinkCmpKindStruct", { fg = colors.blue.hex })
  set_hl("BlinkCmpKindEvent", { fg = colors.blue.hex })
  set_hl("BlinkCmpKindOperator", { fg = colors.sky.hex })
  set_hl("BlinkCmpKindTypeParameter", { fg = colors.maroon.hex })
  set_hl("BlinkCmpKindCopilot", { fg = colors.teal.hex })

  set_hl("BlinkCmpMenuBorder", { fg = colors.blue.hex, bg = "NONE" })
  set_hl("BlinkCmpDocBorder", { link = "FloatBorder" })
end

-- ===========================================
-- GitSigns Integration
-- ===========================================
local function setup_gitsigns()
  set_hl("GitSignsAdd", { fg = colors.green.hex })
  set_hl("GitSignsChange", { fg = colors.yellow.hex })
  set_hl("GitSignsDelete", { fg = colors.red.hex })
  set_hl("GitSignsCurrentLineBlame", { fg = colors.surface1.hex })
  set_hl("GitSignsAddPreview", { fg = colors.green.hex, bg = "NONE" })
  set_hl("GitSignsDeletePreview", { fg = colors.red.hex, bg = "NONE" })
  set_hl("GitSignsAddInline", { fg = colors.base.hex, bg = colors.green.hex, bold = true })
  set_hl("GitSignsDeleteInline", { fg = colors.base.hex, bg = colors.red.hex, bold = true })
  set_hl("GitSignsChangeInline", { fg = colors.base.hex, bg = colors.blue.hex, bold = true })
  set_hl("GitSignsDeleteVirtLn", { bg = "NONE", fg = colors.red.hex })
end

-- ===========================================
-- Telescope Integration
-- ===========================================
local function setup_telescope()
  set_hl("TelescopeBorder", { link = "FloatBorder" })
  set_hl("TelescopeNormal", { link = "NormalFloat" })
  set_hl("TelescopePreviewNormal", { link = "TelescopeNormal" })
  set_hl("TelescopePromptNormal", { link = "TelescopeNormal" })
  set_hl("TelescopeResultsNormal", { link = "TelescopeNormal" })
  set_hl("TelescopeTitle", { link = "FloatTitle" })
  set_hl("TelescopeSelectionCaret", { fg = colors.flamingo.hex, bg = "NONE" })
  set_hl("TelescopeSelection", { fg = colors.flamingo.hex, bg = "NONE", bold = true })
  set_hl("TelescopeMatching", { fg = colors.blue.hex })
  set_hl("TelescopePromptPrefix", { fg = colors.flamingo.hex })
  set_hl("TelescopePreviewTitle", { fg = colors.crust.hex, bg = colors.green.hex })
  set_hl("TelescopePromptTitle", { fg = colors.crust.hex, bg = colors.red.hex })
  set_hl("TelescopeResultsTitle", { fg = colors.crust.hex, bg = colors.lavender.hex })
end

-- ===========================================
-- Noice Integration
-- ===========================================
local function setup_noice()
  set_hl("NoiceCmdline", { fg = colors.text.hex })
  set_hl("NoiceCmdlineIcon", { fg = colors.sky.hex, italic = true })
  set_hl("NoiceCmdlineIconSearch", { fg = colors.yellow.hex })
  set_hl("NoiceCmdlinePopupBorder", { fg = colors.lavender.hex })
  set_hl("NoiceCmdlinePopupBorderSearch", { fg = colors.yellow.hex })
  set_hl("NoiceConfirmBorder", { fg = colors.blue.hex })
  set_hl("NoiceMini", { fg = colors.subtext0.hex, blend = 0 })
  set_hl("NoiceFormatProgressDone", { bg = "NONE", fg = colors.subtext0.hex })
  set_hl("NoiceFormatProgressTodo", { bg = "NONE", fg = colors.subtext0.hex })
end

-- ===========================================
-- Snacks Integration
-- ===========================================
local function setup_snacks()
  set_hl("SnacksNormal", { link = "Normal" })
  set_hl("SnacksWinBar", { link = "Title" })
  set_hl("SnacksBackdrop", { link = "FloatShadow" })
  set_hl("SnacksNormalNC", { link = "NormalFloat" })
  set_hl("SnacksWinBarNC", { link = "SnacksWinBar" })

  set_hl("SnacksNotifierInfo", { fg = colors.blue.hex })
  set_hl("SnacksNotifierIconInfo", { fg = colors.blue.hex })
  set_hl("SnacksNotifierTitleInfo", { fg = colors.blue.hex, italic = true })
  set_hl("SnacksNotifierFooterInfo", { link = "DiagnosticInfo" })
  set_hl("SnacksNotifierBorderInfo", { fg = colors.blue.hex })
  set_hl("SnacksNotifierWarn", { fg = colors.yellow.hex })
  set_hl("SnacksNotifierIconWarn", { fg = colors.yellow.hex })
  set_hl("SnacksNotifierTitleWarn", { fg = colors.yellow.hex, italic = true })
  set_hl("SnacksNotifierBorderWarn", { fg = colors.yellow.hex })
  set_hl("SnacksNotifierFooterWarn", { link = "DiagnosticWarn" })
  set_hl("SnacksNotifierDebug", { fg = colors.peach.hex })
  set_hl("SnacksNotifierIconDebug", { fg = colors.peach.hex })
  set_hl("SnacksNotifierTitleDebug", { fg = colors.peach.hex, italic = true })
  set_hl("SnacksNotifierBorderDebug", { fg = colors.peach.hex })
  set_hl("SnacksNotifierFooterDebug", { link = "DiagnosticHint" })
  set_hl("SnacksNotifierError", { fg = colors.red.hex })
  set_hl("SnacksNotifierIconError", { fg = colors.red.hex })
  set_hl("SnacksNotifierTitleError", { fg = colors.red.hex, italic = true })
  set_hl("SnacksNotifierBorderError", { fg = colors.red.hex })
  set_hl("SnacksNotifierFooterError", { link = "DiagnosticError" })
  set_hl("SnacksNotifierTrace", { fg = colors.rosewater.hex })
  set_hl("SnacksNotifierIconTrace", { fg = colors.rosewater.hex })
  set_hl("SnacksNotifierTitleTrace", { fg = colors.rosewater.hex, italic = true })
  set_hl("SnacksNotifierBorderTrace", { fg = colors.rosewater.hex })
  set_hl("SnacksNotifierFooterTrace", { link = "DiagnosticHint" })

  set_hl("SnacksDashboardNormal", { link = "Normal" })
  set_hl("SnacksDashboardDesc", { fg = colors.blue.hex })
  set_hl("SnacksDashboardFile", { fg = colors.lavender.hex })
  set_hl("SnacksDashboardDir", { link = "NonText" })
  set_hl("SnacksDashboardFooter", { fg = colors.yellow.hex, italic = true })
  set_hl("SnacksDashboardHeader", { fg = colors.blue.hex })
  set_hl("SnacksDashboardIcon", { fg = colors.pink.hex, bold = true })
  set_hl("SnacksDashboardKey", { fg = colors.peach.hex })
  set_hl("SnacksDashboardTerminal", { link = "SnacksDashboardNormal" })
  set_hl("SnacksDashboardSpecial", { link = "Special" })
  set_hl("SnacksDashboardTitle", { link = "Title" })

  set_hl("SnacksIndent", { fg = colors.surface0.hex })
  set_hl("SnacksIndentScope", { fg = colors.overlay2.hex })

  set_hl("SnacksPickerSelected", { fg = colors.flamingo.hex, bg = "NONE", bold = true })
  set_hl("SnacksPickerMatch", { fg = colors.blue.hex })

  set_hl("SnacksPicker", { link = "NormalFloat" })
  set_hl("SnacksPickerBorder", { link = "FloatBorder" })
  set_hl("SnacksPickerInputBorder", { link = "SnacksPickerBorder" })
  set_hl("SnacksPickerInput", { link = "NormalFloat" })
  set_hl("SnacksPickerPrompt", { fg = colors.flamingo.hex })

  set_hl("SnacksPickerTitle", { fg = colors.crust.hex, bg = colors.mauve.hex })
  set_hl("SnacksPickerPreviewTitle", { fg = colors.crust.hex, bg = colors.green.hex })
  set_hl("SnacksPickerInputTitle", { fg = colors.crust.hex, bg = colors.red.hex })
  set_hl("SnacksPickerListTitle", { fg = colors.crust.hex, bg = colors.lavender.hex })
end

-- ===========================================
-- Diffview Integration
-- ===========================================
local function setup_diffview()
  set_hl("DiffviewDim1", { link = "Comment" })
  set_hl("DiffviewPrimary", { fg = colors.blue.hex })
  set_hl("DiffviewSecondary", { fg = colors.green.hex })
  set_hl("DiffviewNormal", { fg = colors.text.hex, bg = "NONE" })
  set_hl("DiffviewWinSeparator", { fg = colors.base.hex, bg = "NONE" })
  set_hl("DiffviewFilePanelTitle", { fg = colors.blue.hex, bold = true })
  set_hl("DiffviewFilePanelCounter", { fg = colors.text.hex })
  set_hl("DiffviewFilePanelRootPath", { fg = colors.lavender.hex, bold = true })
  set_hl("DiffviewFilePanelFileName", { fg = colors.text.hex })
  set_hl("DiffviewFilePanelSelected", { fg = colors.yellow.hex })
  set_hl("DiffviewFilePanelPath", { link = "Comment" })
  set_hl("DiffviewFilePanelInsertions", { fg = colors.green.hex })
  set_hl("DiffviewFilePanelDeletions", { fg = colors.red.hex })
  set_hl("DiffviewFilePanelConflicts", { fg = colors.yellow.hex })
  set_hl("DiffviewFolderName", { fg = colors.blue.hex, bold = true })
  set_hl("DiffviewFolderSign", { fg = colors.blue.hex })
  set_hl("DiffviewHash", { fg = colors.flamingo.hex })
  set_hl("DiffviewReference", { fg = colors.blue.hex, bold = true })
  set_hl("DiffviewReflogSelector", { fg = colors.pink.hex })
  set_hl("DiffviewStatusAdded", { fg = colors.green.hex })
  set_hl("DiffviewStatusUntracked", { fg = colors.green.hex })
  set_hl("DiffviewStatusModified", { fg = colors.yellow.hex })
  set_hl("DiffviewStatusRenamed", { fg = colors.yellow.hex })
  set_hl("DiffviewStatusCopied", { fg = colors.yellow.hex })
  set_hl("DiffviewStatusTypeChange", { fg = colors.yellow.hex })
  set_hl("DiffviewStatusUnmerged", { fg = colors.yellow.hex })
  set_hl("DiffviewStatusUnknown", { fg = colors.red.hex })
  set_hl("DiffviewStatusDeleted", { fg = colors.red.hex })
  set_hl("DiffviewStatusBroken", { fg = colors.red.hex })
  set_hl("DiffviewStatusIgnored", { fg = colors.overlay0.hex })
end

-- ===========================================
-- Mini Integration
-- ===========================================
local function setup_mini()
  set_hl("MiniAnimateCursor", { reverse = true, nocombine = true })
  set_hl("MiniAnimateNormalFloat", { link = "NormalFloat" })

  set_hl("MiniClueBorder", { link = "FloatBorder" })
  set_hl("MiniClueDescGroup", { link = "DiagnosticFloatingWarn" })
  set_hl("MiniClueDescSingle", { link = "NormalFloat" })
  set_hl("MiniClueNextKey", { link = "DiagnosticFloatingHint" })
  set_hl("MiniClueNextKeyWithPostkeys", { link = "DiagnosticFloatingError" })
  set_hl("MiniClueSeparator", { link = "DiagnosticFloatingInfo" })
  set_hl("MiniClueTitle", { link = "FloatTitle" })

  set_hl("MiniCompletionActiveParameter", { underline = true })

  set_hl("MiniCursorword", { underline = true })
  set_hl("MiniCursorwordCurrent", { underline = true })

  set_hl("MiniDepsChangeAdded", { link = "diffAdded" })
  set_hl("MiniDepsChangeRemoved", { link = "diffRemoved" })
  set_hl("MiniDepsHint", { link = "DiagnosticHint" })
  set_hl("MiniDepsInfo", { link = "DiagnosticInfo" })
  set_hl("MiniDepsMsgBreaking", { link = "DiagnosticWarn" })
  set_hl("MiniDepsPlaceholder", { link = "Comment" })
  set_hl("MiniDepsTitle", { link = "Title" })
  set_hl("MiniDepsTitleError", { bg = colors.red.hex, fg = colors.base.hex })
  set_hl("MiniDepsTitleSame", { link = "DiffText" })
  set_hl("MiniDepsTitleUpdate", { bg = colors.green.hex, fg = colors.base.hex })

  set_hl("MiniDiffSignAdd", { fg = colors.green.hex })
  set_hl("MiniDiffSignChange", { fg = colors.yellow.hex })
  set_hl("MiniDiffSignDelete", { fg = colors.red.hex })
  set_hl("MiniDiffOverAdd", { link = "DiffAdd" })
  set_hl("MiniDiffOverChange", { link = "DiffText" })
  set_hl("MiniDiffOverContext", { link = "DiffChange" })
  set_hl("MiniDiffOverDelete", { link = "DiffDelete" })

  set_hl("MiniFilesBorder", { link = "FloatBorder" })
  set_hl("MiniFilesBorderModified", { link = "DiagnosticFloatingWarn" })
  set_hl("MiniFilesCursorLine", { link = "CursorLine" })
  set_hl("MiniFilesDirectory", { link = "Directory" })
  set_hl("MiniFilesFile", { fg = colors.text.hex })
  set_hl("MiniFilesNormal", { link = "NormalFloat" })
  set_hl("MiniFilesTitle", { link = "FloatTitle" })
  set_hl("MiniFilesTitleFocused", { fg = colors.crust.hex, bg = colors.mauve.hex })

  set_hl("MiniHipatternsFixme", { fg = colors.base.hex, bg = colors.red.hex, bold = true })
  set_hl("MiniHipatternsHack", { fg = colors.base.hex, bg = colors.yellow.hex, bold = true })
  set_hl("MiniHipatternsNote", { fg = colors.base.hex, bg = colors.sky.hex, bold = true })
  set_hl("MiniHipatternsTodo", { fg = colors.base.hex, bg = colors.teal.hex, bold = true })

  set_hl("MiniIconsAzure", { fg = colors.sapphire.hex })
  set_hl("MiniIconsBlue", { fg = colors.blue.hex })
  set_hl("MiniIconsCyan", { fg = colors.teal.hex })
  set_hl("MiniIconsGreen", { fg = colors.green.hex })
  set_hl("MiniIconsGrey", { fg = colors.text.hex })
  set_hl("MiniIconsOrange", { fg = colors.peach.hex })
  set_hl("MiniIconsPurple", { fg = colors.mauve.hex })
  set_hl("MiniIconsRed", { fg = colors.red.hex })
  set_hl("MiniIconsYellow", { fg = colors.yellow.hex })

  set_hl("MiniIndentscopeSymbol", { fg = colors.overlay2.hex })

  set_hl("MiniJump", { fg = colors.overlay2.hex, bg = colors.pink.hex })

  set_hl("MiniJump2dDim", { fg = colors.overlay0.hex })
  set_hl("MiniJump2dSpot", { bg = "NONE", fg = colors.peach.hex, bold = true, underline = true })
  set_hl("MiniJump2dSpotAhead", { bg = "NONE", fg = colors.teal.hex })
  set_hl("MiniJump2dSpotUnique", { bg = "NONE", fg = colors.sky.hex, bold = true })

  set_hl("MiniMapNormal", { link = "NormalFloat" })
  set_hl("MiniMapSymbolCount", { link = "Special" })
  set_hl("MiniMapSymbolLine", { link = "Title" })
  set_hl("MiniMapSymbolView", { link = "Delimiter" })

  set_hl("MiniNotifyBorder", { link = "FloatBorder" })
  set_hl("MiniNotifyNormal", { link = "NormalFloat" })
  set_hl("MiniNotifyTitle", { link = "FloatTitle" })

  set_hl("MiniOperatorsExchangeFrom", { link = "IncSearch" })

  set_hl("MiniPickBorder", { link = "FloatBorder" })
  set_hl("MiniPickBorderBusy", { link = "DiagnosticFloatingWarn" })
  set_hl("MiniPickBorderText", { fg = colors.mauve.hex, bg = "NONE" })
  set_hl("MiniPickIconDirectory", { link = "Directory" })
  set_hl("MiniPickIconFile", { link = "MiniPickNormal" })
  set_hl("MiniPickHeader", { link = "DiagnosticFloatingHint" })
  set_hl("MiniPickMatchCurrent", { fg = colors.flamingo.hex, bg = "NONE", bold = true })
  set_hl("MiniPickMatchMarked", { link = "Visual" })
  set_hl("MiniPickMatchRanges", { link = "DiagnosticFloatingHint" })
  set_hl("MiniPickNormal", { link = "NormalFloat" })
  set_hl("MiniPickPreviewLine", { link = "CursorLine" })
  set_hl("MiniPickPreviewRegion", { link = "IncSearch" })
  set_hl("MiniPickPrompt", { fg = colors.text.hex, bg = "NONE" })
  set_hl("MiniPickPromptCaret", { fg = colors.flamingo.hex, bg = "NONE" })
  set_hl("MiniPickPromptPrefix", { fg = colors.flamingo.hex, bg = "NONE" })

  set_hl("MiniStarterCurrent", {})
  set_hl("MiniStarterFooter", { fg = colors.yellow.hex, italic = true })
  set_hl("MiniStarterHeader", { fg = colors.blue.hex })
  set_hl("MiniStarterInactive", { fg = colors.surface2.hex, italic = true })
  set_hl("MiniStarterItem", { fg = colors.text.hex })
  set_hl("MiniStarterItemBullet", { fg = colors.blue.hex })
  set_hl("MiniStarterItemPrefix", { fg = colors.pink.hex })
  set_hl("MiniStarterSection", { fg = colors.flamingo.hex })
  set_hl("MiniStarterQuery", { fg = colors.green.hex })

  set_hl("MiniStatuslineDevinfo", { fg = colors.subtext1.hex, bg = "NONE" })
  set_hl("MiniStatuslineFileinfo", { fg = colors.subtext1.hex, bg = "NONE" })
  set_hl("MiniStatuslineFilename", { fg = colors.text.hex, bg = colors.mantle.hex })
  set_hl("MiniStatuslineInactive", { fg = colors.blue.hex, bg = colors.mantle.hex })
  set_hl("MiniStatuslineModeCommand", { fg = colors.base.hex, bg = colors.peach.hex, bold = true })
  set_hl("MiniStatuslineModeInsert", { fg = colors.base.hex, bg = colors.green.hex, bold = true })
  set_hl("MiniStatuslineModeNormal", { fg = colors.mantle.hex, bg = colors.blue.hex, bold = true })
  set_hl("MiniStatuslineModeOther", { fg = colors.base.hex, bg = colors.teal.hex, bold = true })
  set_hl("MiniStatuslineModeReplace", { fg = colors.base.hex, bg = colors.red.hex, bold = true })
  set_hl("MiniStatuslineModeVisual", { fg = colors.base.hex, bg = colors.mauve.hex, bold = true })

  set_hl("MiniSurround", { bg = colors.pink.hex, fg = colors.surface1.hex })

  set_hl("MiniTablineCurrent", { fg = colors.text.hex, bg = "NONE", sp = colors.red.hex, bold = true, italic = true, underline = true })
  set_hl("MiniTablineFill", { bg = "NONE" })
  set_hl("MiniTablineHidden", { fg = colors.text.hex, bg = "NONE" })
  set_hl("MiniTablineModifiedCurrent", { fg = colors.red.hex, bg = "NONE", bold = true, italic = true })
  set_hl("MiniTablineModifiedHidden", { fg = colors.red.hex, bg = "NONE" })
  set_hl("MiniTablineModifiedVisible", { fg = colors.red.hex, bg = "NONE" })
  set_hl("MiniTablineTabpagesection", { fg = colors.surface1.hex, bg = "NONE" })
  set_hl("MiniTablineVisible", { bg = "NONE" })

  set_hl("MiniTestEmphasis", { bold = true })
  set_hl("MiniTestFail", { fg = colors.red.hex, bold = true })
  set_hl("MiniTestPass", { fg = colors.green.hex, bold = true })

  set_hl("MiniTrailspace", { bg = colors.red.hex })
end

-- ===========================================
-- Trouble Integration
-- ===========================================
local function setup_trouble()
  set_hl("TroubleText", { fg = colors.green.hex })
  set_hl("TroubleCount", { fg = colors.pink.hex, bg = "NONE" })
  set_hl("TroubleNormal", { fg = colors.text.hex, bg = "NONE" })
  set_hl("TroubleNormalNC", { link = "TroubleNormal" })
end

-- ===========================================
-- Neogit Integration
-- ===========================================
local function setup_neogit()
  set_hl("NeogitBranch", { fg = colors.peach.hex, bold = true })
  set_hl("NeogitRemote", { fg = colors.green.hex, bold = true })
  set_hl("NeogitUnmergedInto", { link = "Function" })
  set_hl("NeogitUnpulledFrom", { link = "Function" })
  set_hl("NeogitObjectId", { link = "Comment" })
  set_hl("NeogitStash", { link = "Comment" })
  set_hl("NeogitRebaseDone", { link = "Comment" })
  set_hl("NeogitHunkHeader", { bg = darken(colors.blue.hex, 0.095, colors.base.hex), fg = darken(colors.blue.hex, 0.5, colors.base.hex) })
  set_hl("NeogitHunkHeaderHighlight", { bg = darken(colors.blue.hex, 0.215, colors.base.hex), fg = colors.blue.hex })
  set_hl("NeogitDiffContextHighlight", { bg = "NONE" })
  set_hl("NeogitDiffDeleteHighlight", { bg = darken(colors.red.hex, 0.345, colors.base.hex), fg = lighten(colors.red.hex, 0.85, colors.text.hex) })
  set_hl("NeogitDiffAddHighlight", { bg = darken(colors.green.hex, 0.345, colors.base.hex), fg = lighten(colors.green.hex, 0.85, colors.text.hex) })
  set_hl("NeogitDiffDelete", { bg = darken(colors.red.hex, 0.095, colors.base.hex), fg = darken(colors.red.hex, 0.8, colors.base.hex) })
  set_hl("NeogitDiffDeleteInline", { bg = darken(colors.red.hex, 0.5, colors.base.hex), bold = true })
  set_hl("NeogitDiffAdd", { bg = darken(colors.green.hex, 0.095, colors.base.hex), fg = darken(colors.green.hex, 0.8, colors.base.hex) })
  set_hl("NeogitDiffAddInline", { bg = darken(colors.green.hex, 0.5, colors.base.hex), bold = true })
  set_hl("NeogitCommitViewHeader", { bg = darken(colors.blue.hex, 0.3, colors.base.hex), fg = lighten(colors.blue.hex, 0.8, colors.text.hex) })
  set_hl("NeogitChangeModified", { fg = colors.blue.hex, bold = true })
  set_hl("NeogitChangeDeleted", { fg = colors.red.hex, bold = true })
  set_hl("NeogitChangeAdded", { fg = colors.green.hex, bold = true })
  set_hl("NeogitChangeRenamed", { fg = colors.mauve.hex, bold = true })
  set_hl("NeogitChangeUpdated", { fg = colors.peach.hex, bold = true })
  set_hl("NeogitChangeCopied", { fg = colors.pink.hex, bold = true })
  set_hl("NeogitChangeBothModified", { fg = colors.yellow.hex, bold = true })
  set_hl("NeogitChangeNewFile", { fg = colors.green.hex, bold = true })
  set_hl("NeogitUntrackedfiles", { fg = colors.mauve.hex, bold = true })
  set_hl("NeogitUnstagedchanges", { fg = colors.mauve.hex, bold = true })
  set_hl("NeogitUnmergedchanges", { fg = colors.mauve.hex, bold = true })
  set_hl("NeogitUnpulledchanges", { fg = colors.mauve.hex, bold = true })
  set_hl("NeogitRecentcommits", { fg = colors.mauve.hex, bold = true })
  set_hl("NeogitStagedchanges", { fg = colors.mauve.hex, bold = true })
  set_hl("NeogitStashes", { fg = colors.mauve.hex, bold = true })
  set_hl("NeogitRebasing", { fg = colors.mauve.hex, bold = true })
  set_hl("NeogitNotificationInfo", { fg = colors.blue.hex })
  set_hl("NeogitNotificationWarning", { fg = colors.yellow.hex })
  set_hl("NeogitNotificationError", { fg = colors.red.hex })
  set_hl("NeogitGraphRed", { fg = colors.red.hex })
  set_hl("NeogitGraphWhite", { fg = colors.base.hex })
  set_hl("NeogitGraphYellow", { fg = colors.yellow.hex })
  set_hl("NeogitGraphGreen", { fg = colors.green.hex })
  set_hl("NeogitGraphCyan", { fg = colors.blue.hex })
  set_hl("NeogitGraphBlue", { fg = colors.blue.hex })
  set_hl("NeogitGraphPurple", { fg = colors.lavender.hex })
  set_hl("NeogitGraphGray", { fg = colors.subtext1.hex })
  set_hl("NeogitGraphOrange", { fg = colors.peach.hex })
  set_hl("NeogitGraphBoldRed", { fg = colors.red.hex, bold = true })
  set_hl("NeogitGraphBoldWhite", { fg = colors.text.hex, bold = true })
  set_hl("NeogitGraphBoldYellow", { fg = colors.yellow.hex, bold = true })
  set_hl("NeogitGraphBoldGreen", { fg = colors.green.hex, bold = true })
  set_hl("NeogitGraphBoldCyan", { fg = colors.blue.hex, bold = true })
  set_hl("NeogitGraphBoldBlue", { fg = colors.blue.hex, bold = true })
  set_hl("NeogitGraphBoldPurple", { fg = colors.lavender.hex, bold = true })
  set_hl("NeogitGraphBoldGray", { fg = colors.subtext1.hex, bold = true })
  set_hl("NeogitDiffContext", { bg = "NONE" })
  set_hl("NeogitPopupBold", { bold = true })
  set_hl("NeogitPopupSwitchKey", { fg = colors.lavender.hex })
  set_hl("NeogitPopupOptionKey", { fg = colors.lavender.hex })
  set_hl("NeogitPopupConfigKey", { fg = colors.lavender.hex })
  set_hl("NeogitPopupActionKey", { fg = colors.lavender.hex })
  set_hl("NeogitFilePath", { fg = colors.blue.hex, italic = true })
  set_hl("NeogitDiffHeader", { bg = "NONE", fg = colors.blue.hex, bold = true })
  set_hl("NeogitDiffHeaderHighlight", { bg = "NONE", fg = colors.peach.hex, bold = true })
  set_hl("NeogitUnpushedTo", { fg = colors.lavender.hex, bold = true })
  set_hl("NeogitFold", { fg = "NONE", bg = "NONE" })
  set_hl("NeogitSectionHeader", { fg = colors.mauve.hex, bold = true })
  set_hl("NeogitTagName", { fg = colors.yellow.hex })
  set_hl("NeogitTagDistance", { fg = colors.blue.hex })
  set_hl("NeogitWinSeparator", { link = "WinSeparator" })
end

-- ===========================================
-- Navic Integration (LSP breadcrumbs)
-- ===========================================
local function setup_navic()
  set_hl("NavicIconsFile", { fg = colors.blue.hex, bg = "NONE" })
  set_hl("NavicIconsModule", { fg = colors.blue.hex, bg = "NONE" })
  set_hl("NavicIconsNamespace", { fg = colors.blue.hex, bg = "NONE" })
  set_hl("NavicIconsPackage", { fg = colors.blue.hex, bg = "NONE" })
  set_hl("NavicIconsClass", { fg = colors.yellow.hex, bg = "NONE" })
  set_hl("NavicIconsMethod", { fg = colors.blue.hex, bg = "NONE" })
  set_hl("NavicIconsProperty", { fg = colors.green.hex, bg = "NONE" })
  set_hl("NavicIconsField", { fg = colors.green.hex, bg = "NONE" })
  set_hl("NavicIconsConstructor", { fg = colors.blue.hex, bg = "NONE" })
  set_hl("NavicIconsEnum", { fg = colors.green.hex, bg = "NONE" })
  set_hl("NavicIconsInterface", { fg = colors.yellow.hex, bg = "NONE" })
  set_hl("NavicIconsFunction", { fg = colors.blue.hex, bg = "NONE" })
  set_hl("NavicIconsVariable", { fg = colors.flamingo.hex, bg = "NONE" })
  set_hl("NavicIconsConstant", { fg = colors.peach.hex, bg = "NONE" })
  set_hl("NavicIconsString", { fg = colors.green.hex, bg = "NONE" })
  set_hl("NavicIconsNumber", { fg = colors.peach.hex, bg = "NONE" })
  set_hl("NavicIconsBoolean", { fg = colors.peach.hex, bg = "NONE" })
  set_hl("NavicIconsArray", { fg = colors.peach.hex, bg = "NONE" })
  set_hl("NavicIconsObject", { fg = colors.peach.hex, bg = "NONE" })
  set_hl("NavicIconsKey", { fg = colors.pink.hex, bg = "NONE" })
  set_hl("NavicIconsNull", { fg = colors.peach.hex, bg = "NONE" })
  set_hl("NavicIconsEnumMember", { fg = colors.red.hex, bg = "NONE" })
  set_hl("NavicIconsStruct", { fg = colors.blue.hex, bg = "NONE" })
  set_hl("NavicIconsEvent", { fg = colors.blue.hex, bg = "NONE" })
  set_hl("NavicIconsOperator", { fg = colors.sky.hex, bg = "NONE" })
  set_hl("NavicIconsTypeParameter", { fg = colors.blue.hex, bg = "NONE" })
  set_hl("NavicText", { fg = colors.sapphire.hex, bg = "NONE" })
  set_hl("NavicSeparator", { fg = colors.text.hex, bg = "NONE" })
end

-- ===========================================
-- Terminal Colors
-- ===========================================
local function setup_terminal()
  vim.g.terminal_color_0 = colors.overlay0.hex
  vim.g.terminal_color_1 = colors.red.hex
  vim.g.terminal_color_2 = colors.green.hex
  vim.g.terminal_color_3 = colors.yellow.hex
  vim.g.terminal_color_4 = colors.blue.hex
  vim.g.terminal_color_5 = colors.pink.hex
  vim.g.terminal_color_6 = colors.sky.hex
  vim.g.terminal_color_7 = colors.green.hex
  vim.g.terminal_color_8 = colors.overlay1.hex
  vim.g.terminal_color_9 = colors.red.hex
  vim.g.terminal_color_10 = colors.green.hex
  vim.g.terminal_color_11 = colors.yellow.hex
  vim.g.terminal_color_12 = colors.blue.hex
  vim.g.terminal_color_13 = colors.pink.hex
  vim.g.terminal_color_14 = colors.sky.hex
  vim.g.terminal_color_15 = colors.green.hex
end

-- ===========================================
-- Apply all highlights
-- ===========================================
setup_editor()
setup_syntax()
setup_treesitter()
setup_lsp()
setup_neotree()
setup_blink_cmp()
setup_gitsigns()
setup_telescope()
setup_noice()
setup_snacks()
setup_diffview()
setup_mini()
setup_trouble()
setup_neogit()
setup_navic()
setup_terminal()

-- Set colorscheme name
vim.g.colors_name = "mocha"

-- Return the module for lazy.nvim
return M
