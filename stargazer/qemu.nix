let
  guests = {
    ubuntest = {
      memory = "2g";
      vncDisplay = "localhost:1";
      netDevice = "tap0";
      mac = "aa:46:bb:53:79:be";
    };
  };
in { pkgs, lib, ... }: {
  systemd.services = lib.mapAttrs' (name: guest: lib.nameValuePair "qemu-guest-${name}" {
    wantedBy = [ "multi-user.target" ];
    script = ''
      disks=/var/lib/guests/disks/
      mkdir -p $disks

      sock=/run/qemu-${name}.mon.sock

      hda=$disks/${name}.img
      if [[ ! -r $hda ]]; then
        echo "Could not find valid guest image at $hda. Aborting."
        exit 1
      fi

      ${pkgs.qemu_kvm}/bin/qemu-kvm -m ${guest.memory} -display vnc=${guest.vncDisplay} \
        -monitor unix:$sock,server,nowait \
        -netdev tap,id=net0,ifname=${guest.netDevice},script=no,downscript=no \
        -device virtio-net-pci,netdev=net0,mac=${guest.mac} \
        -usbdevice tablet \
        -drive file=$hda,if=virtio,boot=on
    '';

    preStop = ''
      echo 'system_powerdown' | ${pkgs.socat}/bin/socat - UNIX-CONNECT:/run/qemu-${name}.mon.sock
      sleep 10
    '';
  }) guests;

  networking.interfaces = lib.foldl (m: g: m // {${g} = {virtual=true; virtualType="tap";};}) {} (map (g: g.netDevice) (builtins.attrValues guests));
  networking.bridges.br0.interfaces = map (g: g.netDevice) (builtins.attrValues guests);
}
