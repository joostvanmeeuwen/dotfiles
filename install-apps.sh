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
  org.signal.Signal
)

install_claude_code() {
  if command -v claude &>/dev/null; then
    warn "Claude Code already installed"
    return 0
  fi

  info "Installing Claude Code..."
  curl -fsSL https://claude.ai/install.sh | bash
}

install_gemini_cli() {
  if command -v gemini &>/dev/null; then
    warn "Gemini CLI already installed"
    return 0
  fi

  # Ensure nvm/npm is available in this shell
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

  if ! command -v npm &>/dev/null; then
    error "npm not found. Run install-deps.sh first to install nvm/node."
    exit 1
  fi

  info "Installing Gemini CLI..."
  npm install -g @google/gemini-cli
}

install_jetbrains_toolbox() {
  if [ -f "$HOME/.local/share/JetBrains/Toolbox/bin/jetbrains-toolbox" ]; then
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

  info "Extracting and launching JetBrains Toolbox (installs to ~/.local/share/JetBrains/)..."
  tar -xzf "$tmp_dir/toolbox.tar.gz" -C "$tmp_dir"
  "$tmp_dir"/jetbrains-toolbox-*/jetbrains-toolbox --minimize &

  rm -rf "$tmp_dir"
  info "JetBrains Toolbox launched — it will finish installing itself in the background."
}

install_syncthing() {
  if command -v syncthing &>/dev/null; then
    warn "Syncthing already installed"
    return 0
  fi

  info "Installing Syncthing..."
  case $OS in
  fedora)
    sudo dnf install -y syncthing
    ;;
  ubuntu | debian)
    sudo apt install -y syncthing
    ;;
  *)
    error "Unsupported OS: $OS"
    exit 1
    ;;
  esac

  info "Enabling syncthing user service..."
  systemctl --user enable --now syncthing.service
}

install_zed() {
  if command -v zed &>/dev/null; then
    warn "Zed already installed"
    return 0
  fi

  info "Installing Zed..."
  curl -f https://zed.dev/install.sh | sh
}

install_flatpak_apps() {
  if ! command -v flatpak &>/dev/null; then
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
  install_flatpak_apps
  install_claude_code
  install_gemini_cli
  install_jetbrains_toolbox
  install_zed
  info "All applications installed successfully!"
}

main "$@"
