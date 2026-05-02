#!/usr/bin/env bash

set -e

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/helpers.sh"

ARCH=$(uname -m)

create_tools_dir() {
    info "Creating ~/tools directory structure..."
    mkdir -p "$HOME/tools/wordlists" "$HOME/tools/scripts"
}

install_dnf_packages() {
    info "Installing penetration testing packages via dnf..."
    sudo dnf install -y \
        nmap masscan whois bind-utils net-tools \
        gobuster hydra \
        john hashcat \
        socat nmap-ncat tcpdump wireshark-cli \
        smbclient openvpn \
        binwalk foremost strace ltrace steghide perl-Image-ExifTool \
        gdb radare2 \
        python3-pip ruby ruby-devel gcc make openssl \
        libpcap-devel autoconf automake libtool
}

install_nikto() {
    if command_exists nikto; then
        warn "nikto already installed"
        return 0
    fi

    info "Installing nikto (web server scanner)..."
    git clone --depth 1 https://github.com/sullo/nikto "$HOME/tools/nikto"
    sudo ln -sf "$HOME/tools/nikto/program/nikto.pl" /usr/local/bin/nikto
    sudo chmod +x "$HOME/tools/nikto/program/nikto.pl"
}

install_netdiscover() {
    if command_exists netdiscover; then
        warn "netdiscover already installed"
        return 0
    fi

    info "Installing netdiscover (ARP network scanner)..."
    local tmp_dir
    tmp_dir=$(mktemp -d)
    git clone --depth 1 https://github.com/netdiscover-scanner/netdiscover "$tmp_dir/netdiscover"
    (cd "$tmp_dir/netdiscover" && autoreconf -i && ./configure && make && sudo make install)
    rm -rf "$tmp_dir"
}

install_dirb() {
    if command_exists dirb; then
        warn "dirb already installed"
        return 0
    fi

    info "Installing dirb (web content scanner)..."
    local tmp_dir
    tmp_dir=$(mktemp -d)
    curl -fsSL "https://sourceforge.net/projects/dirb/files/dirb/2.22/dirb222.tar.gz/download" \
        -o "$tmp_dir/dirb.tar.gz"
    tar xzf "$tmp_dir/dirb.tar.gz" -C "$tmp_dir"
    (cd "$tmp_dir/dirb222" && ./configure && make && sudo make install)
    rm -rf "$tmp_dir"
}

install_crunch() {
    if command_exists crunch; then
        warn "crunch already installed"
        return 0
    fi

    info "Installing crunch (wordlist generator)..."
    local tmp_dir
    tmp_dir=$(mktemp -d)
    curl -fsSL "https://sourceforge.net/projects/crunch-wordlist/files/crunch-wordlist/crunch-3.6.tgz/download" \
        -o "$tmp_dir/crunch.tgz"
    tar xzf "$tmp_dir/crunch.tgz" -C "$tmp_dir"
    (cd "$tmp_dir/crunch-3.6" && make && sudo make install)
    rm -rf "$tmp_dir"
}

install_ffuf() {
    if command_exists ffuf; then
        warn "ffuf already installed"
        return 0
    fi

    if ! command_exists go; then
        warn "Go not found, skipping ffuf — install Go first via install-deps.sh"
        return 0
    fi

    info "Installing ffuf..."
    go install github.com/ffuf/ffuf/v2@latest
}

install_feroxbuster() {
    if command_exists feroxbuster; then
        warn "feroxbuster already installed"
        return 0
    fi

    info "Installing feroxbuster..."

    local latest_version
    latest_version=$(curl -s https://api.github.com/repos/epi052/feroxbuster/releases/latest | jq -r .tag_name)
    if [ -z "$latest_version" ] || [ "$latest_version" = "null" ]; then
        warn "Failed to fetch feroxbuster version, using fallback"
        latest_version="v2.10.4"
    fi

    local asset_name
    case $ARCH in
        x86_64)
            asset_name="x86_64-linux-feroxbuster.zip"
            ;;
        aarch64)
            asset_name="aarch64-linux-feroxbuster.zip"
            ;;
        *)
            error "Unsupported architecture for feroxbuster: $ARCH"
            return 1
            ;;
    esac

    local tmp_dir
    tmp_dir=$(mktemp -d)
    curl -fsSL "https://github.com/epi052/feroxbuster/releases/download/${latest_version}/${asset_name}" \
        -o "$tmp_dir/feroxbuster.zip"
    unzip -q "$tmp_dir/feroxbuster.zip" feroxbuster -d "$tmp_dir"
    sudo install -m 755 "$tmp_dir/feroxbuster" /usr/local/bin/feroxbuster
    rm -rf "$tmp_dir"
}

install_python_tools() {
    if command_exists pwn && command_exists sqlmap && command_exists enum4linux-ng; then
        warn "Python pen testing tools already installed"
        return 0
    fi

    info "Installing Python pen testing tools (pwntools, impacket, ROPgadget, sqlmap, enum4linux-ng)..."
    pip3 install --user pwntools impacket ROPgadget sqlmap enum4linux-ng
}

install_ruby_tools() {
    if command_exists wpscan && command_exists evil-winrm && command_exists zsteg; then
        warn "Ruby pen testing tools already installed"
        return 0
    fi

    info "Installing Ruby pen testing tools (wpscan, evil-winrm, zsteg)..."
    gem install wpscan evil-winrm zsteg
}

install_pwndbg() {
    if [ -d "$HOME/.pwndbg" ]; then
        warn "pwndbg already installed"
        return 0
    fi

    info "Installing pwndbg (GDB enhancement for binary exploitation)..."
    git clone https://github.com/pwndbg/pwndbg "$HOME/.pwndbg"
    "$HOME/.pwndbg/setup.sh"
}

install_metasploit() {
    if command_exists msfconsole; then
        warn "Metasploit Framework already installed"
        return 0
    fi

    info "Installing Metasploit Framework..."
    local tmp_installer
    tmp_installer=$(mktemp)
    curl -fsSL \
        https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb \
        -o "$tmp_installer"
    chmod +x "$tmp_installer"
    "$tmp_installer"
    rm -f "$tmp_installer"
}

install_burpsuite() {
    if [ -d "$HOME/BurpSuiteCommunity" ]; then
        warn "Burp Suite Community already installed"
        return 0
    fi

    info "Installing Burp Suite Community Edition..."

    local burp_type
    case $ARCH in
        x86_64)
            burp_type="Linux"
            ;;
        aarch64)
            burp_type="LinuxArm64"
            ;;
        *)
            error "Unsupported architecture for Burp Suite: $ARCH"
            return 1
            ;;
    esac

    local tmp_installer
    tmp_installer=$(mktemp --suffix=.sh)
    curl -fsSL "https://portswigger.net/burp/releases/download?product=community&type=${burp_type}" \
        -o "$tmp_installer"
    chmod +x "$tmp_installer"
    "$tmp_installer" -q
    rm -f "$tmp_installer"
}

install_privesc_scripts() {
    info "Installing privilege escalation scripts..."

    if [ ! -f "$HOME/tools/scripts/linpeas.sh" ]; then
        info "Downloading linpeas..."
        curl -fsSL \
            https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh \
            -o "$HOME/tools/scripts/linpeas.sh"
        chmod +x "$HOME/tools/scripts/linpeas.sh"
    else
        warn "linpeas already downloaded"
    fi

    local pspy_binary
    case $ARCH in
        x86_64)
            pspy_binary="pspy64"
            ;;
        aarch64)
            warn "No official pspy ARM64 binary available"
            warn "Compile manually: go install github.com/DominicBreuker/pspy@latest"
            return 0
            ;;
        *)
            warn "No pspy binary for architecture: $ARCH"
            return 0
            ;;
    esac

    if [ ! -f "$HOME/tools/scripts/$pspy_binary" ]; then
        info "Downloading pspy ($pspy_binary)..."
        curl -fsSL \
            "https://github.com/DominicBreuker/pspy/releases/latest/download/${pspy_binary}" \
            -o "$HOME/tools/scripts/$pspy_binary"
        chmod +x "$HOME/tools/scripts/$pspy_binary"
    else
        warn "pspy already downloaded"
    fi
}

install_wordlists() {
    info "Installing wordlists..."

    if [ ! -d "$HOME/tools/wordlists/SecLists" ]; then
        warn "Downloading SecLists (~2GB) — this may take a while..."
        git clone --depth 1 https://github.com/danielmiessler/SecLists \
            "$HOME/tools/wordlists/SecLists"
    else
        warn "SecLists already downloaded"
    fi

    if [ ! -f "$HOME/tools/wordlists/rockyou.txt" ]; then
        info "Downloading rockyou.txt..."
        curl -fsSL \
            https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt \
            -o "$HOME/tools/wordlists/rockyou.txt"
    else
        warn "rockyou.txt already downloaded"
    fi
}

main() {
    info "Starting hackerhat installation..."

    detect_os
    info "Detected OS: $OS"

    if [[ "$OS" != "fedora" ]]; then
        error "hackerhat.sh only supports Fedora (detected: $OS)"
        exit 1
    fi

    info "Detected architecture: $ARCH"

    create_tools_dir
    install_dnf_packages
    install_nikto
    install_netdiscover
    install_dirb
    install_crunch
    install_ffuf
    install_feroxbuster
    install_python_tools
    install_ruby_tools
    install_pwndbg
    install_metasploit
    install_burpsuite
    install_privesc_scripts
    install_wordlists

    info "Hackerhat installation complete!"
    info "  Tools dir:  ~/tools/"
    info "  Wordlists:  ~/tools/wordlists/"
    info "  Scripts:    ~/tools/scripts/"
    info "  Burp Suite: ~/BurpSuiteCommunity/BurpSuiteCommunity"
    warn "Add ~/go/bin to PATH for ffuf (done via install-deps.sh if used)"
    warn "Add ~/.local/bin to PATH for pwntools/ROPgadget (pip --user installs)"
}

main "$@"
