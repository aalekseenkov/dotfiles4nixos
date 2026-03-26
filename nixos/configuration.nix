{ config, pkgs, pkgs-unstable, lib, user, gitName, gitEmail, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./local-networking.nix
  ];

  # --- BOOTLOADER & SYSTEM ---
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda"; # Adjust if using NVMe (/dev/nvme0n1)
    useOSProber = true;
  };
  
  time.timeZone = "Europe/Minsk";
  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; 
  };

  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:alt_shift_toggle,ctrl:nocaps";
  };

  # --- VIRTUALIZATION & HARDWARE ---
  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
  virtualisation.virtualbox.guest.enable = true;
  virtualisation.docker.enable = true;
  zramSwap.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "yes";
    };
  };

  # --- USERS ---
  nix.settings.trusted-users = [ "root" "${user}" ];
  users.users.${user} = {
    isNormalUser = true;
    description = "${gitName}";
    home = "/home/${user}";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  # --- PACKAGES ---
  nixpkgs.config.allowUnfree = true;
  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    git nodejs helix vim yazi starship dconf
    ansible ansible-lint
    yaml-language-server bash-language-server nil marksman
    pkgs-unstable.ansible-language-server
  ];

  environment.variables = {
    EDITOR = "hx";
    VISUAL = "hx";
    STARSHIP_CONFIG = "/home/${user}/.dotfiles/configs/starship/starship.toml";
  };

  programs.git = {
    enable = true;
    config = {
      user.name = "${gitName}";
      user.email = "${gitEmail}";
      safe.directory = [ "/home/${user}/.dotfiles" "*" ];
    };
  };

  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    promptInit = ''eval "$(${pkgs.starship}/bin/starship init zsh)"'';
  };

  # --- SRE AUTOMATION (SYMLINKS & PERMS) ---
  system.activationScripts.postInstall = {
    text = ''
      DOTS="/home/${user}/.dotfiles/configs"
      CONF="/home/${user}/.config"
      mkdir -p "$CONF/helix" "$CONF/starship" "$CONF/yazi"

      ln -sf "$DOTS/helix/config.toml" "$CONF/helix/config.toml"
      ln -sf "$DOTS/helix/languages.toml" "$CONF/helix/languages.toml"
      ln -sf "$DOTS/starship/starship.toml" "$CONF/starship/starship.toml"
      ln -sf "$DOTS/yazi/yazi.toml" "$CONF/yazi/yazi.toml"

      # Ensure permissions for cache and config
      mkdir -p /home/${user}/.cache/yaml-language-server
      chown -R ${user}:users /home/${user}
    '';
    deps = [ "users" ];
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.11";
}

