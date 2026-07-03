{ lib }:
with lib;
with lib.custom;

let
  inherit (builtins) toString;

  # ── Semantic color mappings ──────────────────────────────────────
  # Edit these to globally tweak the theme's relationship to the palette.

  bg = colors.base.hex;
  bgAlt = colors.mantle.hex;
  bgDark = colors.crust.hex;
  surface = colors.surface0.hex;
  surfaceHover = colors.surface1.hex;
  surfaceBorder = colors.surface2.hex;

  fg = colors.text.hex;
  fgAlt = colors.subtext1.hex;
  fgMuted = colors.subtext0.hex;
  fgOverlay = colors.overlay0.hex;

  accent = colors.mauve.hex;
  accentAlt = colors.lavender.hex;
  accentSec = colors.blue.hex;

  red = colors.red.hex;
  green = colors.green.hex;
  yellow = colors.yellow.hex;
  peach = colors.peach.hex;

  selectionBg = accent;
  selectionFg = bg;

  scrollbarSlider = surfaceHover;
  scrollbarHover = surfaceBorder;

  progressFg = accent;
  progressBg = surface;

  buttonFg = fg;
  buttonBg = surface;
  buttonHoverBg = surfaceHover;
  buttonActiveBg = surfaceBorder;

  entryBg = surface;
  entryFg = fg;
  entryBorder = surfaceBorder;

  headerBg = bgAlt;
  headerFg = fg;
  headerBorder = surface;

  menuBg = bgAlt;
  menuFg = fg;
  menuHoverBg = accent;
  menuHoverFg = bg;

  tooltipBg = surface;
  tooltipFg = fg;

  linkFg = accentSec;

  backdropDim = 0.7;
  backdropOpacity = "0.7";
in

''
  /* ── Helios GTK Theme ────────────────────────────────────────────
   *   Generated from Nix at build time via lib.custom.colors.
   *   Edit ~/builds/lib/theme/default.nix to change the palette,
   *   or gtk-theme.nix to change how colors map to widgets.
   * ────────────────────────────────────────────────────────────────── */

  /* ── 1. Global / Base ──────────────────────────────────────────── */

  * {
    background-color: ${bg};
    color: ${fg};
    border-color: ${surfaceBorder};
    border-style: solid;
    outline-color: ${accent};
    -gtk-outline-radius: 4px;
  }

  *:disabled {
    color: ${fgOverlay};
  }

  *:backdrop {
    opacity: ${backdropOpacity};
  }

  /* ── 2. Background & Windows ───────────────────────────────────── */

  .background {
    background-color: ${bg};
  }

  window {
    background-color: ${bg};
  }

  window.background.csd {
    background-color: ${bg};
    border: none;
  }

  window.background.solid-csd {
    background-color: ${bgDark};
    border: 1px solid ${surface};
    border-radius: 0;
  }

  /* ── 3. Text & Labels ──────────────────────────────────────────── */

  label {
    color: ${fg};
  }

  label.separator {
    color: ${fgMuted};
  }

  label:disabled {
    color: ${fgOverlay};
  }

  label:backdrop {
    opacity: ${backdropOpacity};
  }

  /* ── 4. Entries ────────────────────────────────────────────────── */

  entry {
    background-color: ${entryBg};
    color: ${entryFg};
    border: 1px solid ${entryBorder};
    border-radius: 6px;
    padding: 4px 8px;
    caret-color: ${accent};
  }

  entry:focus {
    border-color: ${accent};
    background-color: ${bg};
    outline: none;
  }

  entry:disabled {
    background-color: ${surface};
    color: ${fgOverlay};
    border-color: ${surface};
  }

  entry selection {
    background-color: ${selectionBg};
    color: ${selectionFg};
  }

  /* ── 5. Buttons ────────────────────────────────────────────────── */

  button {
    background-color: ${buttonBg};
    color: ${buttonFg};
    border: 1px solid ${surfaceBorder};
    border-radius: 6px;
    padding: 4px 8px;
    transition: all 100ms ease;
    min-height: 24px;
  }

  button:hover {
    background-color: ${buttonHoverBg};
    border-color: ${buttonHoverBg};
  }

  button:active {
    background-color: ${buttonActiveBg};
    border-color: ${surfaceBorder};
  }

  button:checked {
    background-color: ${accent};
    color: ${selectionFg};
    border-color: ${accent};
  }

  button:checked:hover {
    background-color: ${accentAlt};
    border-color: ${accentAlt};
  }

  button:disabled {
    background-color: ${surface};
    color: ${fgOverlay};
    border-color: ${surface};
  }

  button:backdrop {
    opacity: ${backdropOpacity};
  }

  /* Flat buttons (sidebar items, etc.) */

  button.flat {
    background-color: transparent;
    border-color: transparent;
  }

  button.flat:hover {
    background-color: ${surfaceHover};
  }

  button.flat:checked {
    background-color: ${accent};
    color: ${selectionFg};
  }

  /* Destructive / suggested action */

  button.destructive-action {
    background-color: ${red};
    color: ${selectionFg};
    border-color: ${red};
  }

  button.destructive-action:hover {
    background-color: ${colors.maroon.hex};
    border-color: ${colors.maroon.hex};
  }

  button.suggested-action {
    background-color: ${accent};
    color: ${selectionFg};
    border-color: ${accent};
  }

  button.suggested-action:hover {
    background-color: ${colors.mauve.hex};
    border-color: ${colors.mauve.hex};
  }

  /* ── 6. Selection ──────────────────────────────────────────────── */

  selection {
    background-color: ${selectionBg};
    color: ${selectionFg};
  }

  *:selected {
    background-color: ${selectionBg};
    color: ${selectionFg};
  }

  *:selected:focus {
    background-color: ${accent};
    color: ${selectionFg};
  }

  *:selected:backdrop {
    opacity: ${backdropOpacity};
  }

  /* ── 7. Header Bars & Titlebars ────────────────────────────────── */

  headerbar {
    background-color: ${headerBg};
    color: ${headerFg};
    border-bottom: 1px solid ${headerBorder};
    padding: 4px 8px;
    min-height: 40px;
  }

  headerbar:backdrop {
    opacity: ${backdropOpacity};
  }

  headerbar label {
    color: ${headerFg};
  }

  headerbar button {
    background-color: transparent;
    border-color: transparent;
  }

  headerbar button:hover {
    background-color: ${surfaceHover};
  }

  headerbar button:checked {
    background-color: ${accent};
    color: ${selectionFg};
    border-color: transparent;
  }

  headerbar entry {
    background-color: ${surface};
  }

  headerbar title {
    font-weight: bold;
    padding: 0 8px;
  }

  headerbar subtitle {
    color: ${fgMuted};
    font-size: 0.9em;
  }

  .titlebar {
    background-color: ${headerBg};
    border-bottom: 1px solid ${headerBorder};
  }

  .titlebar:backdrop {
    opacity: ${backdropOpacity};
  }

  /* ── 8. Menus ──────────────────────────────────────────────────── */

  menu {
    background-color: ${menuBg};
    border: 1px solid ${surfaceBorder};
    border-radius: 8px;
    padding: 4px;
  }

  menuitem {
    background-color: transparent;
    color: ${menuFg};
    padding: 6px 32px 6px 12px;
    border-radius: 4px;
    min-height: 20px;
  }

  menuitem:hover {
    background-color: ${menuHoverBg};
    color: ${menuHoverFg};
  }

  menuitem:disabled {
    color: ${fgOverlay};
  }

  menu separator,
  menuitem separator {
    background-color: ${surfaceBorder};
    margin: 4px 0;
    min-height: 1px;
  }

  /* ── 9. Scrollbars ─────────────────────────────────────────────── */

  scrollbar {
    background-color: transparent;
    border: none;
    min-width: 10px;
    min-height: 10px;
  }

  scrollbar trough {
    background-color: transparent;
    border: none;
    border-radius: 5px;
  }

  scrollbar slider {
    background-color: ${scrollbarSlider};
    border: none;
    border-radius: 5px;
    min-width: 6px;
    min-height: 6px;
    margin: 2px;
  }

  scrollbar slider:hover {
    background-color: ${scrollbarHover};
  }

  scrollbar slider:active {
    background-color: ${accent};
  }

  scrollbar.dragging slider {
    background-color: ${accent};
  }

  /* ── 10. Tooltips ──────────────────────────────────────────────── */

  tooltip {
    background-color: ${tooltipBg};
    color: ${tooltipFg};
    border: 1px solid ${surfaceBorder};
    border-radius: 6px;
    padding: 6px 10px;
  }

  tooltip.background {
    background-color: ${tooltipBg};
  }

  tooltip label {
    color: ${tooltipFg};
  }

  /* ── 11. Lists, Trees & Views ──────────────────────────────────── */

  treeview {
    background-color: ${bg};
    color: ${fg};
    border: none;
  }

  treeview.view {
    background-color: ${bg};
    color: ${fg};
    padding: 2px 4px;
  }

  treeview.view:selected {
    background-color: ${selectionBg};
    color: ${selectionFg};
  }

  treeview.view:hover {
    background-color: ${surfaceHover};
  }

  treeview.view:selected:hover {
    background-color: ${accent};
    color: ${selectionFg};
  }

  treeview header button {
    background-color: ${bgAlt};
    color: ${fg};
    border: 1px solid ${surface};
    padding: 4px 8px;
  }

  treeview header button:hover {
    background-color: ${surfaceHover};
  }

  .view {
    background-color: ${bg};
    color: ${fg};
  }

  .view:selected {
    background-color: ${selectionBg};
    color: ${selectionFg};
  }

  .view:selected:hover {
    background-color: ${accent};
  }

  .view:hover {
    background-color: ${surfaceHover};
  }

  column-header {
    background-color: ${bgAlt};
  }

  /* ── 12. Progress Bars ─────────────────────────────────────────── */

  progressbar {
    background-color: transparent;
    border: none;
  }

  progressbar trough {
    background-color: ${progressBg};
    border: 1px solid ${surfaceBorder};
    border-radius: 4px;
    min-height: 6px;
  }

  progressbar progress {
    background-color: ${progressFg};
    border: none;
    border-radius: 4px;
    min-height: 6px;
  }

  progressbar:backdrop {
    opacity: ${backdropOpacity};
  }

  /* ── 13. Scales (Sliders) ──────────────────────────────────────── */

  scale {
    background-color: transparent;
    border: none;
  }

  scale trough {
    background-color: ${progressBg};
    border: 1px solid ${surfaceBorder};
    border-radius: 4px;
    min-height: 6px;
    min-width: 6px;
  }

  scale highlight {
    background-color: ${progressFg};
    border: none;
    border-radius: 4px;
  }

  scale slider {
    background-color: ${progressFg};
    border: none;
    border-radius: 50%;
    min-height: 16px;
    min-width: 16px;
    margin: -6px;
  }

  scale slider:hover {
    background-color: ${accentAlt};
  }

  scale slider:active {
    background-color: ${accent};
  }

  scale value {
    color: ${fgMuted};
  }

  /* ── 14. Checkboxes & Radio Buttons ────────────────────────────── */

  checkbutton,
  radiobutton {
    color: ${fg};
  }

  check,
  radio {
    background-color: ${surface};
    border: 1px solid ${surfaceBorder};
    min-height: 14px;
    min-width: 14px;
  }

  check {
    border-radius: 3px;
  }

  radio {
    border-radius: 50%;
  }

  check:hover,
  radio:hover {
    background-color: ${surfaceHover};
    border-color: ${accent};
  }

  check:checked,
  radio:checked {
    background-color: ${accent};
    border-color: ${accent};
    color: ${selectionFg};
  }

  check:disabled,
  radio:disabled {
    background-color: ${surface};
    color: ${fgOverlay};
  }

  /* ── 15. Switches / Toggles ────────────────────────────────────── */

  switch {
    background-color: ${surface};
    border: 1px solid ${surfaceBorder};
    border-radius: 12px;
    min-height: 20px;
    min-width: 36px;
    padding: 0;
  }

  switch:hover {
    background-color: ${surfaceHover};
  }

  switch:checked {
    background-color: ${accent};
    border-color: ${accent};
  }

  switch slider {
    background-color: ${fgAlt};
    border: none;
    border-radius: 50%;
    min-height: 16px;
    min-width: 16px;
    margin: 2px;
  }

  switch:checked slider {
    background-color: ${selectionFg};
  }

  /* ── 16. Spin Buttons ──────────────────────────────────────────── */

  spinbutton {
    background-color: ${entryBg};
    border: 1px solid ${surfaceBorder};
    border-radius: 6px;
  }

  spinbutton entry {
    border: none;
    background-color: transparent;
  }

  spinbutton button {
    background-color: transparent;
    border: none;
    border-radius: 0;
    padding: 2px 6px;
    min-height: 16px;
    min-width: 16px;
  }

  spinbutton button:hover {
    background-color: ${surfaceHover};
  }

  spinbutton button:active {
    background-color: ${surfaceBorder};
  }

  /* ── 17. Notebooks / Tabs ──────────────────────────────────────── */

  notebook {
    background-color: ${bg};
    border: none;
  }

  notebook header {
    background-color: ${bgAlt};
    border-bottom: 1px solid ${surface};
  }

  notebook tab {
    background-color: transparent;
    color: ${fgAlt};
    padding: 6px 16px;
    border: none;
    border-bottom: 2px solid transparent;
  }

  notebook tab:hover {
    background-color: ${surfaceHover};
  }

  notebook tab:checked {
    color: ${fg};
    border-bottom-color: ${accent};
    background-color: transparent;
  }

  notebook tab button {
    background-color: transparent;
    border: none;
    padding: 0;
    min-height: 16px;
    min-width: 16px;
  }

  notebook tab button:hover {
    background-color: ${surfaceHover};
  }

  /* ── 18. Links ──────────────────────────────────────────────────── */

  link {
    color: ${linkFg};
  }

  link:hover {
    color: ${colors.sapphire.hex};
  }

  link:visited {
    color: ${accent};
  }

  /* ── 19. Frames, Separators & Misc ─────────────────────────────── */

  frame {
    background-color: transparent;
    border: 1px solid ${surface};
    border-radius: 6px;
    padding: 4px;
  }

  frame > border {
    border: none;
  }

  separator {
    background-color: ${surfaceBorder};
    min-height: 1px;
    min-width: 1px;
  }

  paned {
    background-color: ${bg};
  }

  paned separator {
    background-color: ${surface};
    min-width: 2px;
  }

  scrolledwindow {
    background-color: ${bg};
    border: none;
  }

  scrolledwindow.frame {
    border: 1px solid ${surface};
  }

  /* ── 20. Dialog & Info Bars ────────────────────────────────────── */

  dialog {
    background-color: ${bg};
  }

  dialog .dialog-action-area button {
    padding: 8px 16px;
    border-radius: 0;
  }

  dialog .dialog-action-area button:first-child {
    border-bottom-left-radius: 6px;
  }

  dialog .dialog-action-area button:last-child {
    border-bottom-right-radius: 6px;
  }

  infobar {
    border: none;
    border-radius: 6px;
    padding: 4px 8px;
  }

  infobar.info {
    background-color: ${colors.sky.hex};
    color: ${bgDark};
  }

  infobar.warning {
    background-color: ${yellow};
    color: ${bgDark};
  }

  infobar.error {
    background-color: ${red};
    color: ${selectionFg};
  }

  infobar.question {
    background-color: ${accent};
    color: ${selectionFg};
  }

  /* ── 21. Status & Toolbars ─────────────────────────────────────── */

  statusbar {
    background-color: ${bgAlt};
    color: ${fgMuted};
    border-top: 1px solid ${surface};
    padding: 2px 8px;
  }

  toolbar {
    background-color: ${bgAlt};
    border-bottom: 1px solid ${surface};
    padding: 4px;
  }

  searchbar {
    background-color: ${bgAlt};
    border-bottom: 1px solid ${surface};
    padding: 4px;
  }

  /* ── 22. Sidebar ───────────────────────────────────────────────── */

  .sidebar {
    background-color: ${bgAlt};
    color: ${fg};
    border: none;
  }

  .sidebar:backdrop {
    opacity: ${backdropOpacity};
  }

  .sidebar row {
    background-color: transparent;
    color: ${fg};
    padding: 4px 8px;
  }

  .sidebar row:hover {
    background-color: ${surfaceHover};
  }

  .sidebar row:selected {
    background-color: ${accent};
    color: ${selectionFg};
  }

  .sidebar row:selected:hover {
    background-color: ${accentAlt};
  }

  /* ── 23. Calendar / Popovers ───────────────────────────────────── */

  calendar {
    background-color: ${bg};
    color: ${fg};
    border: 1px solid ${surface};
    border-radius: 6px;
    padding: 4px;
  }

  calendar.header {
    background-color: ${bgAlt};
    border-bottom: 1px solid ${surface};
  }

  calendar:selected {
    background-color: ${accent};
    color: ${selectionFg};
  }

  popover {
    background-color: ${menuBg};
    border: 1px solid ${surfaceBorder};
    border-radius: 8px;
    padding: 4px;
  }

  popover.background {
    background-color: ${menuBg};
  }

  /* ── 24. Assistant / ToolbarViews / Misc ───────────────────────── */

  assistant {
    background-color: ${bg};
  }

  toolitem {
    background-color: transparent;
  }

  textview {
    background-color: ${bg};
    color: ${fg};
  }

  textview text {
    background-color: ${bg};
    color: ${fg};
  }

  textview text:selected {
    background-color: ${selectionBg};
    color: ${selectionFg};
  }

  texteditor {
    background-color: ${bg};
    color: ${fg};
  }

  /* ── 25. Dropdown / Combo Box ──────────────────────────────────── */

  combobox {
    background-color: ${buttonBg};
    border: 1px solid ${surfaceBorder};
    border-radius: 6px;
  }

  combobox:hover {
    background-color: ${buttonHoverBg};
  }

  combobox button {
    border: none;
    background-color: transparent;
  }

  combobox window {
    background-color: ${menuBg};
  }
''
