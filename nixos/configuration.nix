{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./local-networking.nix
  ];

  # --- BOOTLOADER & SYSTEM ---
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = true;
  };
  time.timeZone = "Europe/Minsk";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_TIME = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
  };

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    xkb = {
      layout = "us,ru";
      options = "grp:alt_shift_toggle,ctrl:nocaps";
    };
  };

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  # --- GNOME UI SETTINGS ---
  programs.dconf.enable = true;
  systemd.user.services.configure-gnome-keyboard = {
    script = ''
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'us'), ('xkb', 'ru')]"
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/input-sources/xkb-options "['grp:alt_shift_toggle']"
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/mono-font-name "'JetBrainsMono Nerd Font 11'"
    '';
    wantedBy = [ "graphical-session.target" ];
    serviceConfig.Type = "oneshot";
  };

  # --- FONTS & HARDWARE ---
  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
  virtualisation.virtualbox.guest.enable = true;
  virtualisation.docker.enable = true;
  zramSwap.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "yes";
    };
  };

  # --- USERS ---
  nix.settings.trusted-users = [
    "root"
    "ava"
  ];
  users.users.ava = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    shell = pkgs.zsh;
  };

  # --- PACKAGES ---
  nixpkgs.config.allowUnfree = true;
  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    git
    nodejs
    starship
    ansible
    ansible-lint
    yaml-language-server
    bash-language-server
    nil
    marksman
    helix
    vim
    yazi
    dconf
  ];

  environment.variables = {
    EDITOR = "hx";
    VISUAL = "hx";
    ANSIBLE_SKIP_CONFLICT_CHECK = "1";
  };

  programs.git = {
    enable = true;
    config = {
      user.email = "andrew.alekseenkov@yandex.by";
      user.name = "Andrew Alekseenkov";
      safe.directory = [
        "/home/ava/.dotfiles"
        "*"
      ];
    };
  };

  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    promptInit = ''eval "$(${pkgs.starship}/bin/starship init zsh)"'';
  };

  # --- ACTIVATION SCRIPTS ---
  system.activationScripts = {

    binPaths.text = ''
      mkdir -p /usr/bin
      ln -sf ${pkgs.nodejs}/bin/node /usr/bin/node
      ln -sf ${pkgs.yaml-language-server}/bin/yaml-language-server /usr/bin/yaml-language-server
    '';

    userConfigs.text = ''
      DOTS="/home/ava/.dotfiles/configs"
      CONF="/home/ava/.config"
      mkdir -p "$CONF/helix" "$CONF/starship" "$CONF/yazi"

      ln -sf "$DOTS/helix/config.toml" "$CONF/helix/config.toml"
      ln -sf "$DOTS/helix/languages.toml" "$CONF/helix/languages.toml"
      ln -sf "$DOTS/starship/starship.toml" "$CONF/starship.toml"
      ln -sf "$DOTS/yazi/yazi.toml" "$CONF/yazi/yazi.toml"

      touch /home/ava/.zshrc
      chown -R ava:users /home/ava/.config /home/ava/.dotfiles /home/ava/.zshrc
      chmod -R u+rwX /home/ava/.config /home/ava/.dotfiles

      # Создаем папку для кэша схем Red Hat
      mkdir -p /home/ava/.cache/yaml-language-server
      chown -R ava:users /home/ava/.cache/yaml-language-server

    '';
  };

  system.stateVersion = "25.11";
}
