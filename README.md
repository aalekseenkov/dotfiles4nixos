# Bastion: Managed Environment (SRE + DevOps)

## Description

A fully declarative, reproducible, and secure gateway for infrastructure automation.

Powered by **NixOS 25.11**, **Flakes**, and **Helix**.

## The Engine Room: System Architecture

![dotfiles4nixos](./dotfiles4nixos.png)

## Quick Start

If you are on a fresh NixOS install:
1. Login as your user
2. Enter a temporary shell with git: `nix-shell -p git`
3. Clone this repo: `git clone https://github.com/aalekseenkov/dotfiles4nixos.git ~/.dotfiles`
4. Run the bootstrap: `cd ~/.dotfiles && ./ship --reconf`

## 🚀 The `ship` Script: Deployment & Lifecycle

The `ship` script is the orchestrator of the **Bastion 2.0** environment. It automates the "dirty work" of staging local hardware/network configurations and applying system changes safely through NixOS Flakes.

#### Core Commands:
*   **`./ship` — Daily Update**: The standard way to rebuild your system. It uses existing hardware and network configurations to apply updates to your software or dotfiles.
*   **`./ship --reconf` — Reconfigure**: Forces a full reset of local settings. Use this to change your Hostname, Network Interface, or switch between Static and DHCP modes.
*   **`./ship --dhcp` — Rapid DHCP**: A shortcut for non-static environments. It skips static IP prompts and configures the system to use **NetworkManager** and **DHCP** automatically. 
    *   *SRE Tip: Use `./ship --reconf --dhcp` to instantly migrate from a static VM to a laptop/cloud environment.*

#### The Git-Powered Configuration Lifecycle:
To maintain a purely declarative build while keeping private infrastructure data (IPs, Gateway, Hardware UUIDs) out of public repositories, the script follows a specific lifecycle:

1.  **Staging**: It executes `git add -f` on `local-networking.nix` and `hardware-configuration.nix`. This "forces" Nix Flakes to see these files during the build process, even if they are gitignored.
2.  **Building**: It runs `nixos-rebuild switch --flake .#nixos` to apply the new state.
3.  **Cleanup**: Immediately after a successful (or failed) build attempt, it runs `git reset` on these files.
4.  **Result**: Your private infrastructure details remain in the "Not staged for commit" (red) zone. You get a fully reproducible system without ever leaking your private network topology to GitHub.

## Customization (Identity)

To adapt this configuration, edit the variables in the `let` block of your **`flake.nix`**. This is the single source of truth:

```nix
# flake.nix
let
  user = "your_name";               # System username & home directory
  gitName = "Your Full Name";       # Git author name
  gitEmail = "your@email.com";      # Git author email
in
```

## Security & Signing

*   **SSH Signing:** This repo is configured to sign commits using your SSH key.
*   **Verified Status:** Ensure your public SSH key is added to GitHub as a **Signing Key** (not just an Authentication key) to get the "Verified" badge.
*   **Private Data:** `hardware-configuration.nix` and `local-networking.nix` are excluded from commits to keep your infrastructure private.

## Tooling Stack

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
