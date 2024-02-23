{ config, pkgs, ... }:

{

  # Enable the GNOME Desktop Environment.
  services.xserver.desktopManager.gnome.enable = true;
  services.gnome.tracker-miners.enable = false;
  services.gnome.tracker.enable = false;

  environment.systemPackages = with pkgs; [
    switcheroo-control
    gnome.gnome-themes-extra
    gnomeExtensions.pop-shell
    gnomeExtensions.gsconnect
    gnomeExtensions.tiling-assistant
    gnomeExtensions.vitals
    gnomeExtensions.blur-my-shell
    gnomeExtensions.dash-to-panel
    gnomeExtensions.supergfxctl-gex
    gnomeExtensions.applications-menu
    gnomeExtensions.arcmenu
    gnomeExtensions.clipboard-history
    gnomeExtensions.wireless-hid
    gnome.gnome-tweaks
  ];
  
}
