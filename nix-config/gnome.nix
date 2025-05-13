{
  config,
  pkgs,
  ...
}: {
  # Enable the GNOME Desktop Environment.
  services.xserver.desktopManager.gnome.enable = true;
  services.gnome.localsearch.enable = false;
  services.gnome.tinysparql.enable = false;

  environment.systemPackages = with pkgs; [
    mutter
    switcheroo-control
    gnome-themes-extra
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
    gnomeExtensions.appindicator
    gnome-tweaks
    #Hybernate Extention
    #gnomeExtensions.system-action-hibernate
  ];
}
