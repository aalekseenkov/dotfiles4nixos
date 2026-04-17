{
  config,
  pkgs,
  pkgs-unstable,
  lib,
  user,
  gitName,
  gitEmail,
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
  fonts.packages = [
    pkgs.nerd-fonts.intone-mono
    pkgs.nerd-fonts.iosevka
    pkgs.nerd-fonts.jetbrains-mono
  ];
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
  nix.settings.trusted-users = [
    "root"
    "${user}"
  ];
  users.users.${user} = {
    isNormalUser = true;
    description = "${gitName}";
    home = "/home/${user}";
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
    pkgs-unstable.helix
    pkgs-unstable.zellij
    pkgs-unstable.yazi
    pkgs-unstable.ansible-language-server
    pkgs-unstable.bottom
    # pkgs-unstable.k9s
    # kubectl
    # kubernetes-helm
    # terraform
    ansible
    ansible-lint
    sops
    age
    git
    lazygit
    glab
    nil
    yaml-language-server
    bash-language-server
    starship
    taplo
    jq
    # markdown
    marksman
    markdownlint-cli
    python311Packages.grip
    # go
    go
    gopls
    delve
    gotools
    golangci-lint
    golangci-lint-langserver
  ];

  environment.variables = {
    EDITOR = "hx";
    VISUAL = "hx";
    STARSHIP_CONFIG = "/home/${user}/.dotfiles/configs/starship/starship.toml";
    ANSIBLE_HOME = "/home/${user}/.ansible";
  };

  environment.shellAliases = {
    mdview = "grip 0.0.0.0:8080";
  };

  # environment.interactiveShellInit = ''
  #   hx() {
  #     # 1. Set the Helix Background
  #     echo -ne "\033]11;#3B224C\007"
  #     # 2. Launch Helix
  #     command hx "$@"
  #     # 3. Return Terminal Background
  #     echo -ne "\033]11;#008080\007"
  #   }
  # '';

  programs.git = {
    enable = true;
    config = {
      user.name = "${gitName}";
      user.email = "${gitEmail}";

      # --- SSH SIGNING CONFIG ---
      gpg.format = "ssh";
      user.signingkey = "/home/${user}/.ssh/id_ed25519.pub";
      commit.gpgsign = true;
      gpg.ssh.allowedSignersFile = "/home/${user}/.ssh/allowed_signers";

      safe.directory = [
        "/home/${user}/.dotfiles"
        "*"
      ];
    };
  };

  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    shellInit = ''
      export KEYTIMEOUT=1
      zsh-newuser-install() { : }
    '';

    promptInit = ''eval "$(${pkgs.starship}/bin/starship init zsh)"'';
  };

  # --- AUTOMATION (SYMLINKS & PERMISSIONS) ---
  system.activationScripts.postInstall = {
    text = ''
      USER_HOME="/home/${user}"
      DOTS="$USER_HOME/.dotfiles/configs"
      CONF="$USER_HOME/.config"

      CONFIG_DIRS=(
        "helix"
        "starship"
        "yazi"
        "zellij/layouts"
        "glab-cli"
      )

      for dir in "''${CONFIG_DIRS[@]}"; do
        mkdir -p "$CONF/$dir"
      done

      mkdir -p "$USER_HOME/.cache/yaml-language-server"
      mkdir -p "$USER_HOME/.ansible/tmp"
      mkdir -p "$USER_HOME/.grip"

      ln -sf "$DOTS/helix/config.toml" "$CONF/helix/config.toml"
      ln -sf "$DOTS/helix/languages.toml" "$CONF/helix/languages.toml"
      ln -sf "$DOTS/starship/starship.toml" "$CONF/starship/starship.toml"
      ln -sf "$DOTS/yazi/yazi.toml" "$CONF/yazi/yazi.toml"
      ln -sf "$DOTS/zellij/config.kdl" "$CONF/zellij/config.kdl"
      ln -sf "$DOTS/zellij/sre.kdl" "$CONF/zellij/layouts/sre.kdl"

      ln -sf "$DOTS/grip/settings.py" "$USER_HOME/.grip/settings.py"

      chown -R ${user}:users "$CONF"
      chown -R ${user}:users "$USER_HOME/.cache"
      chown -R ${user}:users "$USER_HOME/.ansible"
      chown -R ${user}:users "$USER_HOME/.grip"
    '';
    deps = [ "users" ];
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  system.stateVersion = "25.11";
}
