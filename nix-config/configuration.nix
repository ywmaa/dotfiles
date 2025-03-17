# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, pkgs, ... }:

# Running `nvidia-offload vlc` would run VLC with dGPU
let nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
  export __NV_PRIME_RENDER_OFFLOAD=1
  export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
  export __GLX_VENDOR_LIBRARY_NAME=nvidia
  export __VK_LAYER_NV_optimus=NVIDIA_only

  exec "$@"
'';
unstable = import (builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/nixos-unstable)
{ config = config.nixpkgs.config; };
#nixgl = import (builtins.fetchTarball https://github.com/guibou/nixGL/tarball/main) {};
in

{

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      ./nvim.nix
      #./home-config.nix
      #./lf.nix
      ./vm.nix
      ./dynamic_binaries_support.nix
      ./gnome.nix
      #./hyprland.nix
      #./lomriri.nix
      ./zsh.nix
      ./gpu_and_power.nix
      ./firewall_and_ports.nix
      ./environment_variables.nix
      ./sound.nix
      ./android_tools.nix
      ./time_and_lang.nix
    ];

  #hibernate Support
  boot.resumeDevice = "/dev/nvme0n1p1";

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=10s
  '';
  services.journald.extraConfig = "SystemMaxUse=50M";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;
  boot.loader.systemd-boot.editor = false;
  boot.supportedFilesystems = [ "ntfs" ];
  boot.kernelPackages = pkgs.linuxPackages_zen;#pkgs.linuxPackages_6_12;#pkgs.linuxPackages_latest;
  boot.kernelParams = [ "quiet" "splash" "rd.systemd.show_status=false" "rd.udev.log_level=3" "udev.log_priority=3" ];
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.wantedBy = lib.mkForce [];
  systemd.services."systemd-backlight@leds:platform::kbd_backlight".enable = lib.mkForce false;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  hardware.graphics.enable = true;
  # Enable the GNOME Display Manager.
  services.xserver.displayManager.gdm.enable = true;
#  services.xserver.displayManager.defaultSession = "plasmawayland";
#  services.displayManager.autoLogin.enable = true;
#  services.displayManager.autoLogin.user = "ywmaa";
#  systemd.services."getty@tty1".enable = false;
#  systemd.services."autovt@tty1".enable = false;

  fonts.packages = with pkgs; [ corefonts font-awesome google-fonts ]; #nerdfonts

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = false;
#  services.printing.drivers = [ pkgs.hplipWithPlugin ];

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
   services.libinput.enable = true;

   services.udisks2.enable = true;

  system.autoUpgrade = {
    enable = true;
    flags = [
	"--update-input"
	"nixpkgs"
	"-L"
    ];
#    dates = "02:00";
#    randomizedDelaySec = "45min";

  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ywmaa = {
    isNormalUser = true;
    description = "ywmaa";
    extraGroups = [ "disk" "networkmanager" "wheel" "adbusers"];
    packages = with pkgs; [
    #  firefox
    #  thunderbird
    ];
  };

    #Storage Options
    nix.optimise.automatic = true;
    nix.gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
    #https://github.com/nix-community/nix-direnv
    programs.direnv.enable = true;
    programs.direnv = {
      package = pkgs.direnv;
      silent = false;
      loadInNixShell = true;
      direnvrcExtra = "";
      nix-direnv = {
        enable = true;
        package = pkgs.nix-direnv;
      };
    };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # Enable flatpak
  services.flatpak.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # Enable App Image Support
  boot.binfmt.registrations.appimage = {
    wrapInterpreterInShell = false;
    interpreter = "${pkgs.appimage-run}/bin/appimage-run";
    recognitionType = "magic";
    offset = 0;
    mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
    magicOrExtension = ''\x7fELF....AI\x02'';
  };

  services = {
    syncthing = {
      enable = true;
      group = "users";
      user = "ywmaa";
      configDir = "/home/ywmaa/Documents/.config/syncthing";
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
#    home-manager
#    gparted
#    alacritty
#    gnome.gnome-disk-utility
#    lf
    # TOOLS
    ghex
    p7zip
    #nixgl.auto.nixGLDefault
    libdecor
    appimage-run
#    powertop
    git
    git-lfs
#    verco
#    python3 ToRemove
#    python3.pkgs.pip ToRemove
    neofetch
    neovim
    # APPS
#    gnome.gnome-software
    libreoffice
    firefox
    tor-browser-bundle-bin
    brave
    tor
    proxychains
    guake#libsForQt5.yakuake#guake
#    anydesk
#    vlc
    mpv
    unstable.wineWowPackages.unstableFull
    unstable.dxvk
    unstable.winetricks
#    amberol
    obs-studio
    zoom-us
    gromit-mpx
    vscode
    unstable.code-cursor
#    unstable.unityhub
#    (unstable.unityhub.override { extraLibs = { ... }: [ harfbuzz ]; })
#    chromium
#    google-chrome
#    microsoft-edge
#    waydroid
    wget
    supergfxctl
    nvidia-offload
#    flatpak
#    android-tools
    #hibernate extension
    #gnomeExtensions.system-action-hibernate

    audacity
#    unstable.spotify
    yabridge
    yabridgectl
    carla
    bitwarden
    krita
    gimp
    inkscape
#    darktable
#    unstable.bottles-unwrapped
    telegram-desktop
    unstable.discord
#    fluffychat
    obsidian
#    syncthing
    pandoc
    ffmpeg_6-full
    steam-run
    lutris
    x11vnc
    weylus
    # .NET
    dotnet-sdk_8
#    jdk17
#    jdk11
    libsForQt5.okular
#    wireshark
#    unstable.ventoy-full
    #PMBOOTSTRAP DEPENDs
    openssl
    python3Packages.pytestCheckHook
    ps
    sudo
    multipath-tools

    testdisk
#    unstable.pmbootstrap
  ];

  #Proxy 
  #services.tor.enable = false;
  #services.tor.settings = {
  #      UseBridges = true;
  #      ClientTransportPlugin = "obfs4 exec ${pkgs.obfs4}/bin/obfs4proxy";
  #      Bridge = "obfs4 IP:ORPort [fingerprint]";
  #};

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
