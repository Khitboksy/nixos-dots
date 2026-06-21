{ lib }:
with lib;
with lib.custom;
rec {

  nixos_small = ''
    ${colors.tblue.hex}  \  \ //
    ${colors.tpink.hex} ==${colors.tblue.hex}\__${colors.tpink.hex}\/ ${colors.tblue.hex}//
    ${colors.tpink.hex}   //   \\//
    ${colors.tpink.hex}==${colors.tblue.hex}//     //==
     ${colors.tpink.hex} //${colors.tblue.hex}\___//
    ${colors.tpink.hex}// /\ ${colors.tpink.hex}\  \\==
      ${colors.tblue.hex}// \\  \\
  '';

}
