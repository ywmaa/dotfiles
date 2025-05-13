{
  config,
  pkgs,
  ...
}: {
  # Enable Hyprland

  #Needed for swaylock to work for now
  security.pam.services.swaylock = {};
  nixpkgs.config.permittedInsecurePackages = [
    "electron-24.8.6"
  ];
  services.dbus.enable = true;
  programs.hyprland = {
    package = unstable.hyprland;
    enable = true;
    xwayland.enable = true;
  };
  programs.waybar = {
    enable = true;
    package = pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
    });
  };
  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images

  environment.systemPackages = with pkgs; [
    # Hyprland Apps
    cliphist
    wl-clipboard
    networkmanagerapplet
    pavucontrol
    brightnessctl
    playerctl
    wev
    kitty
    polkit_gnome
    swaylock-effects
    wlogout
    swww
    pywal
    qt5.qtwayland
    qt6.qtwayland
    dunst #mako
    libnotify
    grim
    swappy
    slurp
    rofi-wayland
    xdg-utils
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
  ];
}
