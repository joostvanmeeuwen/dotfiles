# Dotfiles

Personal configuration files for Linux (Fedora/Debian/Ubuntu) and macOS.

## Quick Start

```bash
git clone git@github.com:joostvanmeeuwen/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

./install-deps.sh              # zsh, neovim, tmux, php, go, docker, nvm, fonts, ...
./install-apps.sh              # flatpaks, syncthing, claude, gemini, zed, herdr, jetbrains
./install-gnome-extensions.sh  # GNOME extensions (requires active GNOME session)
./install.sh                   # symlink dotfiles to $HOME
```

## Scripts

| Script | Purpose |
|--------|---------|
| `install-deps.sh` | System packages, starship, docker, nvm, pnpm, ghostty, tmux plugins, zsh plugins, fonts |
| `install-apps.sh` | Flatpak apps, Syncthing, Claude Code, Gemini CLI, Zed, herdr, JetBrains Toolbox |
| `install-gnome-extensions.sh` | Installs and enables GNOME Shell extensions via `gext` |
| `install.sh` | Creates symlinks from `$HOME` to this repo |

Re-running any script is safe — each step checks if it's already done.

## Dotfiles

| File | Symlink | Purpose |
|------|---------|---------|
| `.zshrc` | `~/.zshrc` | Zsh config: starship, fzf, nvm, pnpm, herdr auto-start (tmux fallback) |
| `.aliases` | `~/.aliases` | Shell aliases |
| `.tmux.conf` | `~/.tmux.conf` | Tmux: Catppuccin theme, custom keybinds |
| `.vimrc` | `~/.vimrc` | Vim config |
| `.vim/` | `~/.vim` | Vim colorschemes |
| `.gitconfig` | `~/.gitconfig` | Git config |
| `.config/starship.toml` | `~/.config/starship.toml` | Starship prompt |
| `nvim/` | `~/.config/nvim` | LazyVim-based Neovim config |
| `.config/ghostty/config` | `~/.config/ghostty/config` | Ghostty terminal config |
| `.config/herdr/config.toml` | `~/.config/herdr/config.toml` | herdr multiplexer: `Ctrl+a` prefix, UI options |
| `.config/systemd/user/gcr-ssh-agent.service` | `~/.config/systemd/user/gcr-ssh-agent.service` | Empty override to disable gcr-ssh-agent service (replaced by Bitwarden SSH) |
| `.config/systemd/user/gcr-ssh-agent.socket` | `~/.config/systemd/user/gcr-ssh-agent.socket` | Empty override to disable gcr-ssh-agent socket |
| `.config/environment.d/bitwarden-ssh.conf` | `~/.config/environment.d/bitwarden-ssh.conf` | Sets SSH_AUTH_SOCK to Bitwarden SSH agent socket |

## After Install

- A new shell starts `herdr` automatically; detach with `Ctrl+a q`
- tmux stays available as a manual fallback: run `tmux` and press `Ctrl+a + I` to install tmux plugins
- Run `chsh -s $(which zsh)` to set zsh as default shell
- Log out and back in for shell and docker group changes to take effect
