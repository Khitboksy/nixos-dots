{
  mgr.prepend_keymap = [
    {
      on = "<C-d>";
      run = "plugin drag";
      desc = "Drag files (ripdrag)";
    }
    {
      on = "p";
      run = "plugin smart-paste";
      desc = "Smart paste";
    }

    {
      on = "`c";
      run = "plugin compress";
      desc = "Compress files";
    }

    {
      on = "M";
      run = "plugin mount";
      desc = "Mount manager";
    }

    {
      on = "`p";
      run = "plugin nav-parent-panel";
      desc = "Navigate parent panel";
    }

    {
      on = "F";
      run = "plugin jump-to-char";
      desc = "Jump to char";
    }
  ];

}
