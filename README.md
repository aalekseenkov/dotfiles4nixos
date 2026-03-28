# Yet Another NixOS Dotfiles

Dotfiles are hidden configuration files in Unix-like systems that store settings for shells, editors, and other tools. By managing our dotfiles, we'll ensure a consistent experience across systems and save time reconfiguring tools.

## Installation
1. Install NixOS
2. `mkdir -p ~/.ssh && chmod 700 ~/.ssh`
3. Place `id_ed25519` and `id_ed25519.pub` into `~/.ssh/`
4. `chmod 600 ~/.ssh/id_ed25519`
5. `nix-shell -p git --run "git clone git@github.com:aalekseenkov/dotfiles4nixos.git ~/.dotfiles"`
6. `cd ~/.dotfiles && chmod +x apply && ./apply`

![dotfiles4nixos](./dotfiles4nixos.png)

