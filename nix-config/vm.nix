{ config, pkgs, ... }:

{

  # Add user to libvirtd group
  users.users.ywmaa.extraGroups = [ "libvirtd" ];

  # Install necessary packages
  environment.systemPackages = with pkgs; [
#    looking-glass-client
#    virt-manager
    virt-viewer
    spice spice-gtk
    spice-protocol
    virtiofsd
    win-virtio
    win-spice
  ];

  # Virtual Machine
  programs.virt-manager.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    qemu.swtpm.enable = true;
    qemu.ovmf.enable = true;
    qemu.runAsRoot = true;
    qemu.ovmf.packages = [ pkgs.OVMFFull.fd ];
#    onBoot = "ignore";
#    onShutdown = "shutdown";
  };
  virtualisation.spiceUSBRedirection.enable = true;
  services.spice-vdagentd.enable = true;

#  boot.initrd.availableKernelModules = [ "amdgpu" "vfio-pci" ];
#  boot.initrd.preDeviceCommands = ''
#    DEVS="0000:01:00.0 0000:01:00.1"
#    for DEV in $DEVS; do
#      echo "vfio-pci" > /sys/bus/pci/devices/$DEV/driver_override
#    done
#    modprobe -i vfio-pci
#  '';
#  boot.kernelParams = [ "amd_iommu=on" "iommu=pt" ];
#  boot.kernelModules = [ "kvm-amd" "vfio-pci" ];
#  systemd.tmpfiles.rules = [
#    "f /dev/shm/scream 0660 ywmaa qemu-libvirtd -"
#    "f /dev/shm/looking-glass 0660 alex qemu-libvirtd -"
#  ];

}
