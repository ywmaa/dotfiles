{ config, pkgs, ... }:

{

  # GPU driver and power settings
  #services.auto-cpufreq.enable = true;
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
#  powerManagement.powertop.enable = true;
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
    #nvidiaSettings = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
#    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
#  	version = "560.35.03";
#  	sha256_64bit = "sha256-8pMskvrdQ8WyNBvkU/xPc/CtcYXCa7ekP73oGuKfH+M=";
#  	sha256_aarch64 = "sha256-s8ZAVKvRNXpjxRYqM3E5oss5FdqW+tv1qQC2pDjfG+s=";
#  	openSha256 = "sha256-/32Zf0dKrofTmPZ3Ratw4vDM7B+OgpC4p7s+RHUjCrg=";
#  	settingsSha256 = "sha256-kQsvDgnxis9ANFmwIwB7HX5MkIAcpEEAHc8IBOLdXvk=";
#  	persistencedSha256 = "sha256-E2J2wYYyRu7Kc3MMZz/8ZIemcZg68rkzvqEwFAL3fFs=";
#    };
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
  
}
