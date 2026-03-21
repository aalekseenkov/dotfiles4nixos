{ _config, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # --- BOOTLOADER & SYSTEM ---
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda"; # Adjust if your disk is different
  boot.loader.grub.useOSProber = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Minsk";

  # --- LOCALIZATION & LANGUAGES ---
  # System UI in English
  i18n.defaultLocale = "en_US.UTF-8";

  # Regional settings (Dates, Currency) in Russian
  i18n.extraLocaleSettings = {
    LC_TIME = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
  };

  # Keyboard layouts: US and RU, toggle with Alt+Shift
  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:alt_shift_toggle";
  };

  # Apply XKB settings to the TTY/Console
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; 
  };

  # --- DESKTOP ENVIRONMENT (GNOME) ---
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Force GNOME to apply layouts and show the tray icon
  programs.dconf.enable = true;
  systemd.user.services.configure-gnome-keyboard = {
    script = ''
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'us'), ('xkb', 'ru')]"
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/input-sources/xkb-options "['grp:alt_shift_toggle']"
      # JetBrainsMono Nerd Font
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/mono-font-name "'JetBrainsMono Nerd Font 11'"
      ${pkgs.dconf}/bin/dconf write /org/gnome/console/font-name "'JetBrainsMono Nerd Font 11'"
      ${pkgs.dconf}/bin/dconf write /org/gnome/console/use-system-font "false"
    '';
    wantedBy = [ "graphical-session.target" ];
    serviceConfig.Type = "oneshot";
  };

  # --- FONTS ---
  # Installing only JetBrainsMono Nerd Font
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  # --- HARDWARE & VIRTUALIZATION ---
  virtualisation.virtualbox.guest.enable = true;
  virtualisation.virtualbox.guest.dragAndDrop = true;
  
  # --- ZRAM
  zramSwap.enable = true;
  zramSwap.memoryPercent = 50;

  # --- DOCKER ---
  virtualisation.docker.enable = true;

  # Sound via Pipewire
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # --- NETWORKS ---
  networking = {
    useDHCP = false;
    interfaces.enp0s3.ipv4.addresses = [{
      address = "192.168.100.100"; # Твой статический IP
      prefixLength = 24;
    }];
    defaultGateway = "192.168.100.1"; # IP твоего роутера
    nameservers = [ "8.8.8.8" "1.1.1.1" ];
  }; 

  # --- SSH ---
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "yes"; 
    };
  };

  # --- FIREWALL ---
  networking.firewall.allowedTCPPorts = [ 22 ];
  
  # --- USER ACCOUNT ---
  nix.settings.trusted-users = [ "root" "ava" ];
  users.users.ava = {
    isNormalUser = true;
    description = "AVA";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  # --- PACKAGES & PROGRAMS ---
  nixpkgs.config.allowUnfree = true;
  programs.firefox.enable = true;
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      fuse3
      openssl      
    ];
  };  

  # zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  environment.systemPackages = with pkgs; [
    git
    nodejs_20
    starship
    ansible
    docker-compose
    # lsp
    bash-language-server
    ansible-language-server
    yaml-language-server
    nil
    marksman
    # linters and formatters
    ansible-lint
    yamllint
    nixpkgs-fmt
    # code
    helix
    vim
    yazi
    # system
    dconf   # Required for the keyboard script
  ];

  # starship by default
  programs.zsh.interactiveShellInit = ''
    eval "$(starship init zsh)"
  '';

  #  --- Global environment variables ---
  environment.variables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };

  # --- GIT ---
  programs.git = {
    enable = true;
    config = {
      user.email = "andrew.alekseenkov@yandex.by";
      user.name = "Andrew Alekseenkov";
      commit.gpgsign = true;
      gpg.format = "ssh";
      user.signingkey = "~/.ssh/id_ed25519.pub";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
    };
  };
  # git verification
  system.activationScripts.gitAllowedSigners = {
    text = ''
      mkdir -p /home/ava/.ssh
      echo "andrew.alekseenkov@yandex.by $(cat /home/ava/.ssh/id_ed25519.pub)" > /home/ava/.ssh/allowed_signers
      chown ava:users /home/ava/.ssh/allowed_signers
      chmod 600 /home/ava/.ssh/allowed_signers
    '';
  };

  # --- LSP links for external Zed ---
  system.activationScripts.binPaths = {
    text = ''
      mkdir -p /usr/bin
      ln -sf ${pkgs.nodejs_20}/bin/node /usr/bin/node
      ln -sf ${pkgs.ansible-language-server}/bin/ansible-language-server /usr/bin/ansible-language-server
      ln -sf ${pkgs.yaml-language-server}/bin/yaml-language-server /usr/bin/yaml-language-server
    '';
  };

  # --- CLEAN GARBAGE ---
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # --- AUTO UPGRADE ---
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = false;

  # DO NOT CHANGE: System state version
  system.stateVersion = "24.11";
}
