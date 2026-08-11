{ lib, zenith }:
with zenith.lib';
rec {

  nixos_small = ''
    ${colors.helios.tblue.hex}  \  \ //
    ${colors.helios.tpink.hex} ==${colors.helios.tblue.hex}\__${colors.helios.tpink.hex}\/ ${colors.helios.tblue.hex}//
    ${colors.helios.tpink.hex}   //   \\//
    ${colors.helios.tpink.hex}==${colors.helios.tblue.hex}//     //==
     ${colors.helios.tpink.hex} //${colors.helios.tblue.hex}\___//
    ${colors.helios.tpink.hex}// /\ ${colors.helios.tpink.hex}\  \\==
      ${colors.helios.tblue.hex}// \\  \\
  '';

}
