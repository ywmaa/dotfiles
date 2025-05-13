{
  config,
  pkgs,
  ...
}: {
  # ZSH
  programs.zsh = {
    # Your zsh config
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    ohMyZsh = {
      enable = true;
      plugins = ["git"];
      theme = "agnoster";
    };
  };
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [zsh];
}
