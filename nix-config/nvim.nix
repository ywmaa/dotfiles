{ pkgs, ... }:
{
  environment.variables = { EDITOR = "vim"; };
  environment.systemPackages = with pkgs; [
	(neovim.override {
	  viAlias = true;
      vimAlias = true;
 #     extraConfig = ''
 #       " your custom vimrc
 #       set nocompatible
 #       set backspace=indent,eol,start
 #       " ...
 #     '';
      configure = {
	    customRC = builtins.readFile "/home/ywmaa/.config/nvim/init.vim";
        packages.myVimPlugins = with pkgs.vimPlugins; {
          start = [ vim-lastplace vim-nix vim-plug ]; 
          opt = [];
        };
      };
     }
  )];
}
