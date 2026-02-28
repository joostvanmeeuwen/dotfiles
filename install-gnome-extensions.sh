#!/usr/bin/env bash

set -e

source "$(dirname "$(realpath "$0")")/lib/helpers.sh"

GNOME_EXTENSIONS=(
    dash-to-dock@micxgx.gmail.com
    blur-my-shell@aunetx
    appindicatorsupport@rgcjonas.gmail.com
    clipboard-history@alexsaveau.dev
    AlphabeticalAppGrid@stuarthayhurst
    auto-move-windows@gnome-shell-extensions.gcampax.github.com
    space-bar@luchrioh
    gnome-search-no-as-a-service@vanmeeuwen.dev
)

check_gnome() {
    if [ "$XDG_CURRENT_DESKTOP" != "GNOME" ] && [ "$XDG_SESSION_DESKTOP" != "gnome" ]; then
        error "GNOME desktop not detected. This script requires a running GNOME session."
        exit 1
    fi
}

install_gext() {
    if command -v gext &> /dev/null; then
        warn "gnome-extensions-cli (gext) already installed"
        return 0
    fi

    info "Installing gnome-extensions-cli (gext) via pip3..."
    if ! command -v pip3 &> /dev/null; then
        error "pip3 not found. Install python3-pip via your package manager first."
        exit 1
    fi
    pip3 install --user gnome-extensions-cli

    export PATH="$HOME/.local/bin:$PATH"

    if ! command -v gext &> /dev/null; then
        error "gext installation failed or ~/.local/bin is not in PATH."
        exit 1
    fi
}

install_gnome_extensions() {
    info "Installing GNOME extensions..."
    for ext in "${GNOME_EXTENSIONS[@]}"; do
        if gnome-extensions info "$ext" &> /dev/null; then
            warn "$ext already installed"
        else
            info "Installing $ext..."
            gext install "$ext"
        fi
    done
}

enable_gnome_extensions() {
    info "Enabling GNOME extensions..."
    for ext in "${GNOME_EXTENSIONS[@]}"; do
        if gnome-extensions info "$ext" &> /dev/null; then
            info "Enabling $ext..."
            gnome-extensions enable "$ext"
        else
            warn "$ext not found, skipping enable"
        fi
    done
}

main() {
    info "Starting GNOME extension installation..."
    check_gnome
    install_gext
    install_gnome_extensions
    enable_gnome_extensions
    info "Done! Verify with: gnome-extensions list --enabled"
}

main "$@"
