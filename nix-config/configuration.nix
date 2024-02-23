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
    ];

  #hibernate Support
  boot.resumeDevice = "/dev/nvme0n1p1";

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Africa/Cairo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
  # ZSH
  programs.zsh = {
   # Your zsh config
   enable = true;
   autosuggestions.enable = true;
   syntaxHighlighting.enable = true;
   ohMyZsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "agnoster";
    };
  };
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  hardware.opengl.enable = true;
  # Enable the GNOME Display Manager.
  services.xserver.displayManager.gdm.enable = true;
#  services.xserver.displayManager.defaultSession = "plasmawayland";


  fonts.packages = with pkgs; [ corefonts font-awesome nerdfonts google-fonts ];

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = false;
#  services.printing.drivers = [ pkgs.hplipWithPlugin ];

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
   services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ywmaa = {
    isNormalUser = true;
    description = "ywmaa";
    extraGroups = [ "disk" "networkmanager" "wheel"];
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

   # My Environment Variables
       
    # This is using a rec (recursive) expression to set and access XDG_BIN_HOME within the expression
    # For more on rec expressions see https://nix.dev/tutorials/first-steps/nix-language#recursive-attribute-set-rec

    environment.variables = {
      WINEPREFIX= "$HOME/spitfire"; # for lmms VST loading
#      WINELOADER= "$HOME/.local/share/bottles/runners/soda-7.0-9/bin/wine"; # for lmms VST loading
#      WINEDLLPATH="$HOME/.local/share/bottles/runners/soda-7.0-9/lib/wine/x86_64-unix"; # for lmms VST loading
    };

    programs.java.enable = true;
    environment.sessionVariables = rec {
      POLKIT_AUTH_AGENT = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      XDG_CACHE_HOME  = "$HOME/.cache";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME   = "$HOME/.local/share";
      XDG_STATE_HOME  = "$HOME/.local/state";
      ANDROID_HOME = "$HOME/AndroidDev/android-sdk"; # for Unreal Engine
      NDK_ROOT = "$HOME/AndroidDev/android-sdk/ndk/25.1.8937393"; # for Unreal Engine
      NDKROOT = "$HOME/AndroidDev/android-sdk/ndk/25.1.8937393"; # for Unreal Engine
      JAVA_HOME = "$HOME/android-studio/jbr"; # for Unreal Engine
      LD_LIBRARY_PATH= "$NIX_LD_LIBRARY_PATH";
      PATH = [
        "${ANDROID_HOME}"
        "${NDK_ROOT}"
        "${NDKROOT}"
        "${JAVA_HOME}"
      ];
    };

   # Dotfiles command alias
    environment.interactiveShellInit = ''
      alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
      alias sync_watch='watch -d grep -e Dirty: -e Writeback: /proc/meminfo'
    '';
  # sync watch alias

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # Enable flatpak
  # services.flatpak.enable = true;

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

networking.firewall.allowedTCPPortRanges = [
  # KDE Connect
  { from = 1714; to = 1764; }
];
networking.firewall.allowedUDPPortRanges = [
  # KDE Connect
  { from = 1714; to = 1764; }
];
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    home-manager
    gparted
#    alacritty
#    gnome.gnome-disk-utility
    lf
    # TOOLS
    #nixgl.auto.nixGLDefault
    appimage-run
    powertop
    clang
    clang-tools
    git
    git-lfs
    verco
    python3
    python3.pkgs.pip
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
    anydesk
    vlc
    unstable.wineWowPackages.unstableFull
    unstable.winetricks
#    amberol
    obs-studio
#    zoom-us
    vscode
    chromium
#    google-chrome
    microsoft-edge
#    waydroid
    wget
    supergfxctl
    nvidia-offload
#    flatpak
    android-tools
#    (unstable.blender.override {
#      cudaSupport = true;
#    })
    #hibernate extension
    #gnomeExtensions.system-action-hibernate

#    unstable.godot_4
    unstable.audacity
    unstable.spotify
#    lmms
    authy
    bitwarden
    krita
    darktable
    unstable.bottles-unwrapped
    unstable.telegram-desktop
    discord
#    fluffychat
#    obsidian
    ffmpeg_6-full
    steam-run
    lutris
    jdk17
    jdk11
#    wireshark
#    unstable.ventoy-full
  ];

  #Proxy 
  #services.tor.enable = false;
  #services.tor.settings = {
  #      UseBridges = true;
  #      ClientTransportPlugin = "obfs4 exec ${pkgs.obfs4}/bin/obfs4proxy";
  #      Bridge = "obfs4 IP:ORPort [fingerprint]";
  #};

  # GPU driver and power settings
  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
    battery = {
       governor = "powersave";
       turbo = "never";
    };
    charger = {
       governor = "performance";
       turbo = "auto";
    };
  };
  powerManagement.powertop.enable = true;
  powerManagement.enable = true; 
  services.supergfxd.enable = true;
  hardware.nvidia = {
    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    powerManagement.enable = true;
    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = true;

    # Modesetting is required.
    modesetting.enable = true;

    # Drivers must be at verion 525 or newer
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime   = {
      #sync.enable = true;          # Enable Hybrid Graphics
      offload.enable = true;        # Enable PRIME offloading
      offload.enableOffloadCmd = true;
      #intelBusId     = "PCI:5:0:0"; # lspci | grep VGA | grep Intel
      amdgpuBusId    = "PCI:5:0:0"; # lspci | grep VGA | grep AMD
      nvidiaBusId    = "PCI:1:0:0"; # lspci | grep VGA | grep NVIDIA
    };
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
