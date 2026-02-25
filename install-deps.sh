#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    else
        error "Cannot detect OS"
        exit 1
    fi
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

install_base_packages() {
    info "Installing base packages..."

    case $OS in
        fedora)
            sudo dnf install -y \
                zsh vim neovim tmux xclip wl-clipboard fzf bat tldr \
                git curl wget jq unzip ripgrep fd-find \
                php php-cli php-json php-mbstring php-xml php-zip php-curl \
                php-intl php-pdo php-mysqlnd php-pgsql php-opcache \
                php-gd php-tokenizer php-bcmath \
                golang python3-pip \
                zoxide git-delta
            ;;
        ubuntu|debian)
            sudo apt update
            sudo apt install -y \
                zsh vim neovim tmux xclip wl-clipboard fzf bat \
                git curl wget jq unzip ripgrep fd-find \
                php php-cli php-json php-mbstring php-xml php-zip php-curl \
                php-intl php-pdo php-mysql php-pgsql php-opcache \
                php-gd php-tokenizer php-bcmath \
                golang-go python3-pip \
                zoxide git-delta
            ;;
        *)
            error "Unsupported OS: $OS"
            exit 1
            ;;
    esac
}

install_starship() {
    if command_exists starship; then
        warn "Starship already installed"
        return 0
    fi

    info "Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
}

install_composer() {
    if command_exists composer; then
        warn "Composer already installed"
        return 0
    fi

    info "Installing Composer..."
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php composer-setup.php
    php -r "unlink('composer-setup.php');"
    sudo mv composer.phar /usr/local/bin/composer
}

install_symfony() {
    if command_exists symfony; then
        warn "Symfony CLI already installed"
        return 0
    fi

    info "Installing Symfony CLI..."
    curl -sS https://get.symfony.com/cli/installer | bash
    sudo mv ~/.symfony5/bin/symfony /usr/local/bin/symfony
}

get_latest_nvm_version() {
    local version
    version=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | jq -r .tag_name)

    if [ -z "$version" ] || [ "$version" = "null" ]; then
        error "Failed to fetch latest NVM version, using fallback"
        echo "v0.40.3"
    else
        echo "$version"
    fi
}

# Install NVM
install_nvm() {
    if [ -d "$HOME/.nvm" ]; then
        warn "NVM already installed"
        return 0
    fi

    local nvm_version
    nvm_version=$(get_latest_nvm_version)

    info "Installing NVM ($nvm_version)..."

    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/$nvm_version/install.sh" | bash

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    info "Installing Node.js LTS..."
    nvm install --lts
}

# Install pnpm
install_pnpm() {
    if command_exists pnpm; then
        warn "pnpm already installed"
        return 0
    fi

    info "Installing pnpm..."
    curl -fsSL https://get.pnpm.io/install.sh | sh -
}

# Install Tmux Plugin Manager
install_tpm() {
    if [ -d "$HOME/.tmux/plugins/tpm" ]; then
        warn "TPM already installed"
        return 0
    fi

    info "Installing Tmux Plugin Manager..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

# Install ZSH plugins
install_zsh_plugins() {
    info "Installing ZSH plugins..."

    if [ ! -d "$HOME/.zsh/.zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/.zsh-autosuggestions
    else
        warn "zsh-autosuggestions already installed"
    fi

    if [ ! -d "$HOME/.zsh/.zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/.zsh-syntax-highlighting
    else
        warn "zsh-syntax-highlighting already installed"
    fi
}

install_docker() {
    if command_exists docker; then
        warn "Docker already installed"
    else
        info "Installing Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        rm get-docker.sh
    fi

    # Add user to docker group
    if groups $USER | grep -q '\bdocker\b'; then
        warn "User $USER already in docker group"
    else
        info "Adding $USER to docker group..."
        sudo usermod -aG docker $USER
        warn "You need to log out and back in for docker group membership to take effect"
        warn "Or run: newgrp docker"
    fi

    # Start and enable docker service
    info "Enabling and starting Docker service..."
    sudo systemctl enable docker
    sudo systemctl start docker
}

install_tldr() {
    if command_exists tldr; then
        warn "tldr already installed"
        return 0
    fi

    case $OS in
        fedora)
            # Already installed via dnf
            return 0
            ;;
        ubuntu|debian)
            info "Installing tealdeer (tldr client)..."
            local latest_version
            latest_version=$(curl -s https://api.github.com/repos/tealdeer-rs/tealdeer/releases/latest | jq -r .tag_name)

            if [ -z "$latest_version" ] || [ "$latest_version" = "null" ]; then
                warn "Could not fetch latest version, using direct latest link"
                curl -L https://github.com/tealdeer-rs/tealdeer/releases/latest/download/tealdeer-linux-x86_64-musl -o /tmp/tldr
            else
                curl -L "https://github.com/tealdeer-rs/tealdeer/releases/download/${latest_version}/tealdeer-linux-x86_64-musl" -o /tmp/tldr
            fi

            chmod +x /tmp/tldr
            sudo mv /tmp/tldr /usr/local/bin/tldr

            info "Updating tldr cache..."
            tldr --update
            ;;
    esac
}

install_jetbrains_nerd_font() {
    local font_dir="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"

    if [ -d "$font_dir" ]; then
        warn "JetBrains Mono Nerd Font already installed"
        return 0
    fi

    info "Installing JetBrains Mono Nerd Font..."
    mkdir -p "$font_dir"

    local tmp_dir
    tmp_dir=$(mktemp -d)
    curl -L "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" \
        -o "$tmp_dir/JetBrainsMono.zip"
    unzip -q "$tmp_dir/JetBrainsMono.zip" -d "$font_dir"
    rm -rf "$tmp_dir"

    info "Refreshing font cache..."
    fc-cache -f "$font_dir"
}

# Main installation
main() {
    info "Starting dependency installation..."

    detect_os
    info "Detected OS: $OS"

    # Install everything
    install_base_packages
    install_starship
    install_composer
    install_symfony
    install_docker
    install_nvm
    install_pnpm
    install_tpm
    install_zsh_plugins
    install_tldr
    install_jetbrains_nerd_font

    info "All dependencies installed successfully!"
}

main "$@"
