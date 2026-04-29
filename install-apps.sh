#!/usr/bin/env bash

set -e

source "$(dirname "$(realpath "$0")")/lib/helpers.sh"

FLATPAK_APPS=(
  com.bitwarden.desktop
  com.github.iwalton3.jellyfin-media-player
  com.nextcloud.desktopclient.nextcloud
  com.rtosta.zapzap
  com.spotify.Client
  com.ultimaker.cura
  md.obsidian.Obsidian
  org.gimp.GIMP
  org.inkscape.Inkscape
  org.mozilla.Thunderbird
  org.onlyoffice.desktopeditors
  org.gnome.Extensions
  org.signal.Signal
)

MACOS_CASK_APPS=(
  bitwarden
  jellyfin-media-player
  nextcloud
  whatsapp
  spotify
  ultimaker-cura
  obsidian
  gimp
  inkscape
  thunderbird
  onlyoffice
  signal
)

install_claude_code() {
  if command_exists claude; then
    warn "Claude Code already installed"
    return 0
  fi

  info "Installing Claude Code..."
  curl -fsSL https://claude.ai/install.sh | bash
}

install_opencode() {
  if command_exists opencode; then
    warn "OpenCode already installed"
    return 0
  fi

  info "Installing OpenCode..."
  curl -fsSL https://opencode.ai/install | bash
}

install_gemini_cli() {
  if command_exists gemini; then
    warn "Gemini CLI already installed"
    return 0
  fi

  # Ensure nvm/npm is available in this shell
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

  if ! command_exists npm; then
    error "npm not found. Run install-deps.sh first to install nvm/node."
    exit 1
  fi

  info "Installing Gemini CLI..."
  npm install -g @google/gemini-cli
}

install_jetbrains_toolbox() {
  if [[ "$OS" == "macos" ]]; then
    if brew list --cask jetbrains-toolbox &>/dev/null; then
      warn "JetBrains Toolbox already installed"
      return 0
    fi
    info "Installing JetBrains Toolbox..."
    brew install --cask jetbrains-toolbox
    return 0
  fi

  if [ -d "$HOME/.local/share/JetBrains/Toolbox" ]; then
    warn "JetBrains Toolbox already installed"
    return 0
  fi

  info "Fetching latest JetBrains Toolbox version..."
  local download_url
  download_url=$(curl -s "https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release" |
    jq -r '.TBA[0].downloads.linux.link')

  if [ -z "$download_url" ] || [ "$download_url" = "null" ]; then
    error "Could not fetch JetBrains Toolbox download URL"
    exit 1
  fi

  info "Downloading JetBrains Toolbox..."
  local tmp_dir
  tmp_dir=$(mktemp -d)
  curl -L "$download_url" -o "$tmp_dir/toolbox.tar.gz"

  local install_dir="$HOME/.local/share/JetBrains/Toolbox"
  mkdir -p "$install_dir"

  info "Extracting JetBrains Toolbox..."
  tar -xzf "$tmp_dir/toolbox.tar.gz" -C "$tmp_dir"

  local toolbox_dir
  toolbox_dir=$(find "$tmp_dir" -name "jetbrains-toolbox" -type f -executable | xargs dirname)
  if [ -z "$toolbox_dir" ]; then
    error "Could not find jetbrains-toolbox binary in extracted archive"
    rm -rf "$tmp_dir"
    exit 1
  fi

  mv "$toolbox_dir"/* "$install_dir/"
  rm -rf "$tmp_dir"

  info "Launching JetBrains Toolbox..."
  nohup "$install_dir/jetbrains-toolbox" --minimize > /dev/null 2>&1 &
  disown
  info "JetBrains Toolbox installed to $install_dir"
}

install_syncthing() {
  if command_exists syncthing; then
    warn "Syncthing already installed"
    return 0
  fi

  info "Installing Syncthing..."
  case $OS in
  macos)
    brew install syncthing
    brew services start syncthing
    ;;
  fedora)
    sudo dnf install -y syncthing
    systemctl --user enable --now syncthing.service
    ;;
  ubuntu | debian)
    sudo apt install -y syncthing
    systemctl --user enable --now syncthing.service
    ;;
  *)
    error "Unsupported OS: $OS"
    exit 1
    ;;
  esac
}

install_zed() {
  if command_exists zed; then
    warn "Zed already installed"
    return 0
  fi

  info "Installing Zed..."
  curl -f https://zed.dev/install.sh | sh
}

install_brew_cask_apps() {
  info "Installing macOS apps via Homebrew Cask..."
  for cask in "${MACOS_CASK_APPS[@]}"; do
    if brew list --cask "$cask" &>/dev/null; then
      warn "$cask already installed"
    else
      info "Installing $cask..."
      brew install --cask "$cask"
    fi
  done
}

install_flatpak_apps() {
  if ! command_exists flatpak; then
    error "Flatpak is not installed. Install it first via your package manager."
    exit 1
  fi

  info "Adding Flathub remote (if not already added)..."
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

  info "Installing Flatpak apps..."
  for app in "${FLATPAK_APPS[@]}"; do
    # Strip inline comment
    app_id="${app%%#*}"
    app_id="${app_id// /}"

    if flatpak info "$app_id" &>/dev/null; then
      warn "$app_id already installed"
    else
      info "Installing $app_id..."
      flatpak install -y flathub "$app_id"
    fi
  done
}

main() {
  detect_os
  info "Starting application installation..."
  install_syncthing
  if [[ "$OS" == "macos" ]]; then
    install_brew_cask_apps
  else
    install_flatpak_apps
  fi
  install_claude_code
  install_opencode
  install_gemini_cli
  install_jetbrains_toolbox
  install_zed
  info "All applications installed successfully!"
}

main "$@"
