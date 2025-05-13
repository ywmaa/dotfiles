{
  config,
  pkgs,
  ...
}: let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz";
in {
  imports = [
    (import "${home-manager}/nixos")
  ];

  home-manager.users.ywmaa = {
    /*
    The home.stateVersion option does not have a default and must be set
    */
    home.stateVersion = "23.11";
    /*
    Here goes the rest of your home-manager config, e.g. home.packages = [ pkgs.foo ];
    */
    programs.git = {
      enable = true;
      userName = "ywmaa";
      userEmail = "ywmaa.personal@gmail.com";
    };
    gtk = {
      enable = true;
      theme = {
        name = "Catppuccin-Macchiato-Compact-Cyberpunk";
        package = pkgs.catppuccin-gtk.override {
          accents = ["green" "blue" "pink" "red"];
          size = "compact";
          tweaks = ["rimless" "black"];
          variant = "mocha";
        };
      };
    };
  };
}
