{ config, pkgs, lib, ... }:

let
  helixConfigDir = "/etc/helix";
  helixConfigFile = "${helixConfigDir}/config.toml";
  helixThemesDir = "${helixConfigDir}/runtime/themes";
  cyberpunkThemeFile = "${helixThemesDir}/cyberpunk.toml";
  helixLanguagesFile = "${helixConfigDir}/runtime/languages.toml";
in
{
  options = {
    services.helix.enable = lib.mkEnableOption "Helix editor configuration";
  };

  config = lib.mkIf config.services.helix.enable {
    environment.systemPackages = with pkgs; [
      helix
      clang-tools  # Provides clangd for C/C++
      zls          # Zig Language Server
      nil          # Nix Language Server
      #wgsl_analyzer
      glsl_analyzer
    ];

    system.activationScripts.helixConfig = lib.stringAfter [ "etc" ] ''
      mkdir -p ${helixThemesDir}

      cat > ${helixConfigFile} << EOF
theme = "cyberpunk"
EOF

      cat > ${cyberpunkThemeFile} << EOF
name = "cyberpunk_scarlet"

"ui.background" = { bg = "#101116" }
#"ui.cursor" = { bg = "light_green" }
"ui.cursor.primary.normal" = { bg = "light_green", modifiers = ["dim"] }
"ui.cursor.primary.insert" = { bg = "red", modifiers = ["rapid_blink"] }
"ui.cursor.primary.select" = { bg = "yellow" }
"ui.cursor.normal" = { bg = "light_green", modifiers = ["dim"] }
"ui.cursor.insert" = { bg = "green", modifiers = ["rapid_blink"] }
"ui.cursor.select" = { bg = "yellow" }
"ui.cursor.match" = { bg = "light_green" }
"ui.selection" = { bg = "#f0ff00" }
"ui.selection.primary" = { bg = "#ff00552c" }

#"ui.popup" = {bg = "transparent_yellow" }
"ui.menu.selected" = {fg = "red", bg = "transparent_yellow" }

#Line numbers
"ui.linenr" = { fg = "#ff00557e" }
"ui.linenr.selected" = { fg = "light_green", modifiers = ["bold"] }

# Status bar
"ui.statusline" = { fg = "red", bg = "#1d000ae5" }
"ui.statusline.normal" = { fg = "#1d000ae5", bg = "light_green", modifiers = ["bold"] }
"ui.statusline.insert" = { fg = "#1d000ae5", bg = "red", modifiers = ["bold"] }
"ui.statusline.select" = { fg = "#1d000ae5", bg = "yellow", modifiers = ["bold"] }

"ui.debug" = { fg = "#634450" }
"ui.debug.breakpoint" = { fg = "red" }

#"ui.highlight" = { bg = "yellow" }
#"ui.highlight.frameline" = { bg = "yellow" }


comment = { fg = "#6766b3", modifiers = ["italic"] }
keyword = { fg = "purple", modifiers = ["bold"] }
"keyword.directive" = { fg = "red", modifiers = ["bold"] }
function = { fg = "blue" }
constant = { fg = "yellow" }
string = { fg = "cyan" }
type = { fg = "green" }
"type.paremeter" = { fg = "purple" }
"type.enum" = { fg = "yellow" }
#variable = { fg = "white" }
"variable.builtin" = { fg = "purple" }
"variable.parameter" = { fg = "yellow" }
"variable.other" = { fg = "yellow" }
attribute = { fg = "yellow" }
namespace = { fg = "green", modifiers = ["italic"] }
operator = { fg = "purple" }
special = { fg = "#ff5680" }

# Bracket types
"punctuation.bracket" = { fg = "#d57bff" }
"punctuation.delimiter" = { fg = "#d57bff" }

"diagnostic.error" = { underline = { style = "curl", color = "#ff5370" } }
"diagnostic.warning" = { underline = { style = "curl", color = "#cd9731" } }
"diagnostic.info" = { underline = { style = "curl", color = "#6796e6" } }
"diagnostic.hint" = { underline = { style = "curl", color = "#b267e6" } }

[palette]
red = "#ff0055"
green = "#00ff9c"
light_green = "#00ffc8"
white = "#eeffff"
yellow = "#fffc58"
purple = "#d57bff"
blue = "#00b0ff"
cyan = "#76c1ff"
transparent_yellow = "#fffc5808"
EOF

      cat > ${helixLanguagesFile} << EOF
[language-server.clangd]
command = "clangd"

[language-server.zls]
command = "zls"

[language-server.nil]
command = "nil"

[[language]]
name = "c"
language-servers = ["clangd"]

[[language]]
name = "cpp"
language-servers = ["clangd"]

[[language]]
name = "zig"
language-servers = ["zls"]

[[language]]
name = "nix"
language-servers = ["nil"]
EOF
    '';

    # Set environment variables for Helix to locate the config
    environment.variables = {
      HELIX_CONFIG_DIR = helixConfigDir;
      HELIX_RUNTIME = "${helixConfigDir}/runtime";
    };
  };
}
