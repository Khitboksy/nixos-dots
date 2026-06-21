{ pkgs, lib }:
with lib;
let
  # PCI address parser
  # builtins.split returns interleaved strings + empty-list separators:
  #   split ":" "0000:2b:00.0" → [ "0000" [] "2b" [] "00.0" ]
  #   split "[:.]" "0000:2b:00.0" → [ "0000" [] "2b" [] "00" [] "0" ]
  pciDomain = a: "0x" + (builtins.elemAt (builtins.split ":" a) 0);
  pciBus = a: "0x" + (builtins.elemAt (builtins.split ":" a) 2);
  pciSlot = a: "0x" + (builtins.elemAt (builtins.split "[:.]" a) 4);
  pciFunc = a: builtins.elemAt (builtins.split "[:.]" a) 6;

  # OVMF firmware paths
  ovmfCode = "${pkgs.OVMF.fd}/FV/OVMF_CODE.fd";
  ovmfVars = "${pkgs.OVMF.fd}/FV/OVMF_VARS.fd";

  # Domain XML generator
  genDomainXML =
    name: d:
    let
      # All PCI devices for this domain
      pciDevs = d.gpu.pci ++ d.gpu.audio ++ d.gpu.usb ++ d.gpu.ucsi;

      hostdevs = concatStringsSep "\n" (
        map (addr: ''
          <hostdev mode='subsystem' type='pci' managed='yes'>
            <source>
              <address domain='${pciDomain addr}' bus='${pciBus addr}' slot='${pciSlot addr}' function='${pciFunc addr}'/>
            </source>
          </hostdev>'') pciDevs
      );

      disksXML = ''
        <disk type='file' device='disk'>
          <driver name='qemu' type='qcow2'/>
          <source file='${d.disks.main.path}'/>
          <target dev='vda' bus='virtio'/>
          <boot order='1'/>
        </disk>'';

      cdromXML = optionalString (d.iso != null) ''
        <disk type='file' device='cdrom'>
          <driver name='qemu' type='raw'/>
          <source file='${d.iso}'/>
          <target dev='sda' bus='sata'/>
          <boot order='2'/>
          <readonly/>
        </disk>'';

      virtioXML = optionalString (d.virtioIso != null) ''
        <disk type='file' device='cdrom'>
          <driver name='qemu' type='raw'/>
          <source file='${d.virtioIso}'/>
          <target dev='sdb' bus='sata'/>
          <readonly/>
        </disk>'';

      netXML =
        optionalString (d.network.type == "bridge") ''
          <interface type='bridge'>
            <source bridge='${d.network.bridge}'/>
            <model type='virtio'/>
          </interface>''
        + optionalString (d.network.type == "network") ''
          <interface type='network'>
            <source network='${d.network.name}'/>
            <model type='virtio'/>
          </interface>'';

      osFeatures =
        if d.os == "windows" then
          ''
            <hyperv>
              <relaxed state='on'/>
              <vapic state='on'/>
              <spinlocks state='on' retries='8191'/>
              <vpindex state='on'/>
              <synic state='on'/>
              <stimer state='on'>
                <direct state='on'/>
              </stimer>
              <reset state='on'/>
              <frequencies state='on'/>
            </hyperv>
            <kvm>
              <hidden state='on'/>
            </kvm>
            <vmport state='off'/>''
        else
          ''
            <kvm>
              <hidden state='on'/>
            </kvm>'';

      cpuCores = max 1 (d.vcpu / 2);
      cpuThreads = 2;
      cpuSockets = 1;

      clockXML =
        if d.os == "windows" then
          ''
            <clock offset='localtime'>
              <timer name='hypervclock' present='yes'/>
              <timer name='hpet' present='no'/>
            </clock>''
        else
          ''
            <clock offset='utc'>
              <timer name='kvmclock'/>
            </clock>'';

      firmwareXML =
        if d.firmware == "uefi" then
          ''
            <loader readonly='yes' type='pflash'>${ovmfCode}</loader>
            <nvram template='${ovmfVars}'>/var/lib/libvirt/qemu/nvram/${name}_VARS.fd</nvram>''
        else
          "";

      tpmXML = optionalString d.tpm ''
        <tpm model='tpm-crb'>
          <backend type='emulator' version='2.0'/>
        </tpm>'';

      # Graphics: null = no QEMU display (e.g. GPU passthrough uses monitor directly)
      graphicsXML = optionalString (
        d.graphics != null
      ) "<graphics type='${d.graphics}' port='-1' autoport='yes' listen='0.0.0.0'/>";

      # Video: only include if we have a graphics device
      videoXML = optionalString (d.graphics != null) ''
        <video>
          <model type='qxl'/>
        </video>'';

    in
    ''
      <domain type='kvm'>
        <name>${name}</name>
        <uuid>${d.uuid}</uuid>
        <memory unit='MiB'>${toString d.memory}</memory>
        <currentMemory unit='MiB'>${toString d.memory}</currentMemory>
        <vcpu placement='static'>${toString d.vcpu}</vcpu>

        <os>
          <type arch='x86_64' machine='pc-q35-8.1'>hvm</type>
          ${firmwareXML}
        </os>

        <features>
          <acpi/>
          <apic/>
          ${osFeatures}
        </features>

        <cpu mode='host-passthrough' check='none'>
          <topology sockets='${toString cpuSockets}' dies='1' cores='${toString cpuCores}' threads='${toString cpuThreads}'/>
          <cache mode='passthrough'/>
          <feature policy='require' name='invtsc'/>
        </cpu>

        ${clockXML}

        <on_poweroff>${d.onPoweroff}</on_poweroff>
        <on_reboot>${d.onReboot}</on_reboot>
        <on_crash>${d.onCrash}</on_crash>

        <devices>
          ${disksXML}
          ${cdromXML}
          ${virtioXML}
          ${netXML}
          ${hostdevs}
          ${tpmXML}
          <memballoon model='virtio'/>
          ${graphicsXML}
          ${videoXML}
          <input type='keyboard' bus='ps2'/>
          <input type='mouse' bus='ps2'/>
        </devices>
      </domain>
    '';

in
{
  inherit
    pciDomain
    pciBus
    pciSlot
    pciFunc
    ovmfCode
    ovmfVars
    genDomainXML
    ;
}
