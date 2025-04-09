# Dotfiles

This repository contains my personal configuration files (dotfiles) for a Linux environment. 

## Dependencies

Before following the installation steps, ensure the following software is installed.

**1. Core Applications & Tools:**

Install these using your system's package manager. **Note:** `xclip` has been added as it's used in the tmux config.

* **For openSUSE (using `zypper`):**
```bash
sudo zypper install zsh vim tmux xclip
```

* **For Fedora (using `dnf`):**
```bash
sudo dnf install zsh vim tmux xclip
```

* **For Debian, Ubuntu (using `apt`):**
```bash
sudo apt update && sudo apt install zsh vim tmux xclip
```

**2. Starship:**

Install `starship` using the official installer script (requires `curl` to be installed):
```bash
curl -sS https://starship.rs/install.sh | sh
```

**Required Packages Summary:**
* `zsh`: The shell for which the configuration (`.zshrc`) is intended.
* `vim`: Text editor (configuration in `.vimrc`).
* `tmux`: Terminal multiplexer (configuration in `.tmux.conf`).
* `starship`: Cross-shell prompt (configuration in `.config/starship.toml`).
* `xclip`: Used by tmux config for clipboard integration.

**3. Tmux Plugin Manager (tpm):**

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

**4. Clone the ZSH plugin repositories:**

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh-syntax-highlighting
```

**5. External Tools (NVM / PNPM):**

The `.zshrc` file includes configuration to load Node Version Manager (`nvm`) and set the path for `pnpm`. This setup assumes you have installed `nvm` and `pnpm` separately according to their official documentation (often using `curl` or `npm`). This repository/script does *not* install `nvm` or `pnpm` for you.

## Installation

**1. Clone this repository:**
```bash
git clone git@github.com:joostvanmeeuwen/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

**2. Run the Installation Script:**
This script (which should be present in the repository) creates the necessary symbolic links for files like `.zshrc`, `.tmux.conf`, `.vimrc`, `.aliases`, etc. It will back up any existing files it finds at the target locations.

```bash
chmod +x install.sh
./install.sh
```

**3. Install Tmux Plugins:**
* Start `tmux`.
* Press `prefix` + `I` (capital i). The default prefix is `Ctrl+a` according to your config. This command instructs `tpm` to install the plugins defined in `.tmux.conf`.

**4. (Optional) Change Default Shell to Zsh:**
Use `zsh` as your default login shell:

```bash
chsh -s $(which zsh)
```

Log out and log back in for this change to take effect.
