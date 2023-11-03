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
nixgl = import (builtins.fetchTarball https://github.com/guibou/nixGL/tarball/main) {};
in

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      #Neovim
      ./nvim.nix
      #LF File manager
      #./lf.nix
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
   enableAutosuggestions = true;
   syntaxHighlighting.enable = true;
   oh-my-zsh = {
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
  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  #services.xserver.desktopManager.gnome.enable = true;

  # Enable Hyprland

  #Needed for swaylock to work for now
  security.pam.services.swaylock = {};
  nixpkgs.config.permittedInsecurePackages = [
     "electron-24.8.6"
   ];
  services.dbus.enable = true;
  programs.hyprland = {
     enable = true;
     nvidiaPatches = true;  
  };
  programs.waybar = {
      enable = true;
      package = pkgs.waybar.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
      });
    };
  fonts.fonts = with pkgs; [ font-awesome nerdfonts google-fonts ];

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  #services.printing.enable = true;

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
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  firefox
    #  thunderbird
    ];
  };

    #Storage Options
    nix.optimise.automatic = true;
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

    #nix-ld and envfs for dynamic binaries. 
    services.envfs.enable = true;
    programs.nix-ld.enable = true;        
    
    programs.nix-ld.libraries = with pkgs; [


    # Needed for operating system detection until
    # https://github.com/ValveSoftware/steam-for-linux/issues/5909 is resolved
    lsb-release
    # Errors in output without those
    pciutils
    # Games' dependencies
    xorg.xrandr
    which
    # Needed by gdialog, including in the steam-runtime
    perl
    # Open URLs
    xdg-utils
    iana-etc
    # Steam Play / Proton
    python3
    # Steam VR
    procps
    usbutils

    # It tries to execute xdg-user-dir and spams the log with command not founds
    xdg-user-dirs

    # electron based launchers need newer versions of these libraries than what runtime provides
    sqlite
    # Godot + Blender
    stdenv.cc.cc    
    # Godot Engine
    libunwind

    # Others
    xorg.libXcomposite
    xorg.libXtst
    xorg.libXrandr
    xorg.libXext
    xorg.libX11
    xorg.libXfixes
    libGL
    libva
    libva-utils
    pipewire.lib
    alsaLib
    libpulseaudio
    # steamwebhelper
    harfbuzz
    libthai
    pango

    lsof # friends options won't display "Launch Game" without it
    file # called by steam's setup.sh

    # dependencies for mesa drivers, needed inside pressure-vessel
    mesa
    mesa.llvmPackages.llvm.lib
    vulkan-loader
    expat
    wayland
    xorg.libxcb
    xorg.libXdamage
    xorg.libxshmfence
    xorg.libXxf86vm
    libelf
    (lib.getLib elfutils)

    # Without these it silently fails
    xorg.libXinerama
    xorg.libXcursor
    xorg.libXrender
    xorg.libXScrnSaver
    xorg.libXi
    xorg.libSM
    xorg.libICE
    gnome2.GConf
    curlWithGnuTls
    nspr
    nss
    cups
    libcap
    SDL2
    libusb1
    dbus-glib
    gsettings-desktop-schemas
    ffmpeg
    libudev0-shim

    # Verified games requirements
    fontconfig
    freetype
    xorg.libXt
    xorg.libXmu
    libogg
    libvorbis
    SDL
    SDL2_image
    glew110
    libidn
    tbb
    zlib

    # SteamVR
    udev
    dbus

    # Other things from runtime
    glib
    gtk2
    bzip2
    flac
    freeglut
    libjpeg
    libpng
    libpng12
    libsamplerate
    libmikmod
    libtheora
    libtiff
    pixman
    speex
    SDL_image
    SDL_ttf
    SDL_mixer
    SDL2_ttf
    SDL2_mixer
    libappindicator-gtk2
    libdbusmenu-gtk2
    libindicator-gtk2
    libcaca
    libcanberra
    libgcrypt
    libvpx
    librsvg
    xorg.libXft
    libvdpau

    # required by coreutils stuff to run correctly
    # Steam ends up with LD_LIBRARY_PATH=<bunch of runtime stuff>:/usr/lib:<etc>
    # which overrides DT_RUNPATH in our binaries, so it tries to dynload the
    # very old versions of stuff from the runtime.
    # FIXME: how do we even fix this correctly
    attr

    # Not formally in runtime but needed by some games
    at-spi2-atk
    at-spi2-core   # CrossCode
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-plugins-base
    json-glib # paradox launcher (Stellaris)
    libdrm
    libxkbcommon # paradox launcher
    libvorbis # Dead Cells
    libxcrypt # Alien Isolation, XCOM 2, Company of Heroes 2
    mono
    xorg.xkeyboardconfig
    xorg.libpciaccess
    xorg.libXScrnSaver # Dead Cells
    icu # dotnet runtime, e.g. Stardew Valley

    # screeps dependencies
    gtk3
    dbus
    zlib
    atk
    cairo
    freetype
    gdk-pixbuf
    fontconfig

    # Prison Architect
    libGLU
    libuuid
    libbsd
    alsa-lib

    # Loop Hero
    libidn2
    libpsl
    nghttp2.lib
    rtmpdump
    ];

    # My Environment Variables
       
    # This is using a rec (recursive) expression to set and access XDG_BIN_HOME within the expression
    # For more on rec expressions see https://nix.dev/tutorials/first-steps/nix-language#recursive-attribute-set-rec


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
      WINEPREFIX= "$HOME/spitfire"; # for lmms VST loading
      WINELOADER= "$HOME/.local/share/bottles/runners/soda-7.0-9/bin/wine"; # for lmms VST loading
      WINEDLLPATH="$HOME/.local/share/bottles/runners/soda-7.0-9/lib/wine/x86_64-unix"; # for lmms VST loading
      LD_LIBRARY_PATH= "$NIX_LD_LIBRARY_PATH";
      PATH = [
	"${WINELOADER}"
	"${WINEPREFIX}"
        "${WINEDLLPATH}"
        "${LD_LIBRARY_PATH}"
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
    killall
    gnome.nautilus
    # Hyprland Apps
    cliphist
    wl-clipboard
    networkmanagerapplet
    pavucontrol
    brightnessctl
    playerctl
    wev
    kitty
    #hyprpaper
    polkit_gnome
    swaylock-effects
    wlogout
    swww
    pywal
    qt5.qtwayland
    qt6.qtwayland
    dunst#mako
    libnotify
    grim
    swappy
    slurp
    rofi-wayland
    xdg-utils
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
    lf
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    nixgl.auto.nixGLDefault
    appimage-run
    powertop
    patchelf
    libunwind
    clang
    clang-tools
    git
    git-lfs
    python3
    python3.pkgs.pip
    python38
    python38.pkgs.pip
    scons
    pkg-config
    gcc
    neofetch
    neovim
    gnome.gnome-software
    libreoffice
    firefox
    tor-browser-bundle-bin
    brave
    tor
    proxychains
    guake
    anydesk
    vlc
    unstable.wineWowPackages.unstableFull
    unstable.winetricks
    amberol
    obs-studio
#    zoom-us
    vscode
    chromium
    google-chrome
    microsoft-edge
    waydroid
    wget
    supergfxctl
    nvidia-offload
    switcheroo-control
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
    flatpak
    android-tools
    (unstable.blender.override {
      cudaSupport = true;
    })

    gnome.gnome-tweaks
    #hibernate extension
    gnomeExtensions.system-action-hibernate
    unstable.godot_4
    unstable.audacity
    unstable.spotify
    lmms
    authy
    bitwarden
    krita
    darktable
    discord
    fluffychat
    obsidian
    ffmpeg_6-full
    steam-run
    glibc
    pciutils
    jdk17
    jdk11
    unstable.lenovo-legion
    wireshark
    virt-manager
    looking-glass-client
  ];

  #Proxy 
  services.tor.enable = false;
  services.tor.settings = {
        UseBridges = true;
        ClientTransportPlugin = "obfs4 exec ${pkgs.obfs4}/bin/obfs4proxy";
        Bridge = "obfs4 IP:ORPort [fingerprint]";
  };


  # Virtual Machine
  virtualisation.libvirtd = {
    enable = true;
    qemuOvmf = true;
    qemuRunAsRoot = false;
    onBoot = "ignore";
    onShutdown = "shutdown";
  };
  programs.dconf.enable = true; # virt-manager requires dconf to remember settings


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
    open = true;
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
