# NixOS Configuration (25.11 + Flakes)

This repository contains a declarative configuration for a headless NixOS SRE/DevOps environment. It features a hybrid setup using **NixOS 25.11 (Stable)** with **Unstable** channels for critical tools like the Ansible Language Server.

![dotfiles4nixos](./dotfiles4nixos.png)

## 🚀 Quick Start

If you are on a fresh NixOS install:
1. Login as your user
2. Enter a temporary shell with git: `nix-shell -p git`
3. Clone this repo: `git clone https://github.com/aalekseenkov/dotfiles4nixos.git ~/.dotfiles`
4. Run the bootstrap: `cd ~/.dotfiles && ./ship --reconf`

## 🛠 The `ship` Script

The `ship` script is the heart of this setup. It automates the "dirty work" of staging local hardware configs and applying changes safely.

*   `./ship` — **Daily Update**: Rebuilds the system using existing hardware and network configs.
*   `./ship --reconf` — **Reconfigure**: Re-runs the interactive network setup (Static/DHCP, Hostname, Interface).

It also handles the lifecycle of your configuration:

1.  **Staging:** It runs `git add -f` on your local hardware and network configs. This makes them visible to **Nix Flakes** for the build.
2.  **Building:** It executes `nixos-rebuild switch`.
3.  **Cleanup:** Immediately after, it runs `git reset`. 

**Result:** Your local IP and Hardware UUIDs stay in the "Not staged for commit" (red) zone. They are never pushed to GitHub, keeping your private infrastructure data safe while maintaining a fully declarative build.

## 👤 Customization (Identity)

To adapt this configuration, edit the variables in the `let` block of your **`flake.nix`**. This is the single source of truth:

```nix
# flake.nix
let
  user = "your_name";               # System username & home directory
  gitName = "Your Full Name";       # Git author name
  gitEmail = "your@email.com";      # Git author email
in
```

## 🔐 Security & Signing

*   **SSH Signing:** This repo is configured to sign commits using your SSH key.
*   **Verified Status:** Ensure your public SSH key is added to GitHub as a **Signing Key** (not just an Authentication key) to get the "Verified" badge.
*   **Private Data:** `hardware-configuration.nix` and `local-networking.nix` are excluded from commits to keep your infrastructure private.

## 💻 Tooling Stack

*   **Editor:** Helix (`hx`) with specialized LSPs:
    *   `ansible-language-server` (Forced Unstable version)
    *   `yaml-language-server`
    *   `bash-language-server`
    *   `nil` (Nix LSP)
    *   `marksman` (Markdown LSP)
*   **Shell:** Zsh + **Starship**. Features a custom **two-line prompt** for deep directory navigation and Git status visibility.
*   **Utils:** Yazi (terminal file manager), Docker, and Zram support.

---
*Maintained by aalekseenkov. "Ship it!"*
