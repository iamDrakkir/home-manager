{
  config,
  pkgs,
  lib,
  inputs,
  nixGL,
  # hyprland,
  zen-browser,
  hyprpanel,
  ...
}:
  let
    wrapElectronApp = app: name: pkgs.writeShellScriptBin name ''
      exec ${app}/bin/${name} --no-sandbox "$@"
    '';
  in {
    nixGL = {
      packages = nixGL.packages; # you must set this or everything will be a noop
      defaultWrapper = "mesa"; # choose from nixGL options depending on GPU
    };

    home = {
      username = "drakkir";
      homeDirectory = "/home/drakkir";
      stateVersion = "23.11";
      packages = with pkgs; [
        # hyprland
        hyprlock # issue with unlocking
        # hypridle works, but need to fix hyprlock
        hyprpaper
        wlogout
        # waybar
        hyprpanel.packages.x86_64-linux.wrapper
        hyprpanel
        # rofi-wayland
        bibata-cursors
        # catppuccin-grub - handled by Ubuntu
        # catppuccin-sddm - handled by Ubuntu
        # swaynotificationcenter
        wl-clipboard
        cliphist
        wtype # used by super+w

        xdg-desktop-portal-gtk

        # apps
        # (config.lib.nixGL.wrap ghostty) is wrap needed at all? what is the difference?
        (config.lib.nixGL.wrap alacritty)
        (config.lib.nixGL.wrap kitty)
        (wrapElectronApp _1password-gui "1password")
        (wrapElectronApp discord "discord")
        (zen-browser.packages.x86_64-linux.default)
        _1password-cli
        corectrl # issues, dependencies?
        deluge
        ghostty
        # bottles# issues, currently solved with https://ubuntu.com/blog/ubuntu-23-10-restricted-unprivileged-user-namespaces so it atleast starts.
        # lutris # issues, currently solved with https://ubuntu.com/blog/ubuntu-23-10-restricted-unprivileged-user-namespaces so it atleast starts.
        # flatpak # installed with apt, bwrap issue, same as for lutris and bottles
        mangohud
        nautilus # why is normal nautilus not working?
        vlc

        # cli
        bat
        btop
        curl
        eza
        fd
        fzf
        git
        lazygit
        neovim
        nerd-fonts.jetbrains-mono
        node2nix
        nodejs_24
        python314
        ripgrep
        stow
        uv
        zoxide
        zsh # issue with chsh, perhaps use default zsh instead
      ];
    };

    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };

    programs.home-manager.enable = true;

    xdg.configFile."environment.d/envvars.conf".text = ''
      PATH="$HOME/.nix-profile/bin:$PATH"
    '';

    xdg.desktopEntries."1password" = {
      name = "1Password";
      genericName = "Password Manager";
      comment = "Manage your passwords and credentials";
      exec = "1password";
      icon = "1password";
      terminal = false;
      categories = [ "Utility" "Security" ];
    };
    xdg.desktopEntries."discord" = {
      name = "Discord";
      exec = "discord";
      icon = "discord";
      terminal = false;
      categories = [ "Network" "Chat" ];
    };

    xdg.configFile."hypr".source = "/home/drakkir/.dotfiles/hypr/.config/hypr";

    wayland.windowManager.hyprland = {
      enable = true;
      package = config.lib.nixGL.wrap pkgs.hyprland;
      # package = config.lib.nixGL.wrap (pkgs.hyprland.override {
      #   wrapRuntimeDeps = false;
      # });
    };

    xdg.enable=true;
    xdg.mime.enable=true;
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        # xdg-desktop-portal-hyprland   # the Hyprland‐native portal backend
        # (config.lib.nixGL.wrap pkgs.hyprland)
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];

      configPackages = [ /* pkgs.hyprland */ ];
      config = {
        hyprland.default = [ "wlr" "gtk" ];
      };
    };
  }
