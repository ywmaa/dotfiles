{ config, pkgs, ... }:

{

    # My Environment Variables
       
    # This is using a rec (recursive) expression to set and access XDG_BIN_HOME within the expression
    # For more on rec expressions see https://nix.dev/tutorials/first-steps/nix-language#recursive-attribute-set-rec

    environment.variables = {
    #  WINEPREFIX= "$HOME/spitfire"; # for lmms VST loading
    };

    programs.java.enable = true;
    environment.sessionVariables = rec {
      POLKIT_AUTH_AGENT = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      XDG_CACHE_HOME  = "$HOME/.cache";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME   = "$HOME/.local/share";
      XDG_STATE_HOME  = "$HOME/.local/state";
      PMBOOTSTRAP  = "$HOME/.local/bin";
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
	      "${PMBOOTSTRAP}"
      ];
    };

    # Dotfiles command alias
    environment.interactiveShellInit = ''
      alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
      alias sync_watch='watch -d grep -e Dirty: -e Writeback: /proc/meminfo'
      alias weylus_adb_ports='adb reverse tcp:1701 tcp:1701 && adb reverse tcp:9001 tcp:9001'
    '';
  
}
