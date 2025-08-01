#!/usr/bin/env bash

DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

link_dotfile() {
    local source_file="$DOTFILES_DIR/$1"
    local target_link="$HOME/$2"
    local target_dir

    target_dir=$(dirname "$target_link")

    if [ ! -e "$source_file" ]; then
        echo " ERROR: Source file '$source_file' not found. Skipping."
        return 1
    fi

    if [ ! -d "$target_dir" ]; then
        echo " INFO: Creating target directory '$target_dir'."
        mkdir -p "$target_dir"
    fi

    if [ -e "$target_link" ] || [ -L "$target_link" ]; then
        if [ -L "$target_link" ] && [ "$(readlink "$target_link")" = "$source_file" ]; then
            echo " OK: Link '$target_link' already exists and points correctly."
            return 0
        else
            if [ ! -d "$BACKUP_DIR" ]; then
                echo " INFO: Creating backup directory '$BACKUP_DIR'."
                mkdir -p "$BACKUP_DIR"
            fi
            echo " WARN: '$target_link' already exists. Backing up to '$BACKUP_DIR/$(basename "$target_link")'."
            mv -f "$target_link" "$BACKUP_DIR/"
        fi
    fi

    echo " LINK: '$source_file' -> '$target_link'"
    ln -s "$source_file" "$target_link"
}

echo "Starting dotfile linking process..."

link_dotfile ".zshrc" ".zshrc"
link_dotfile ".tmux.conf" ".tmux.conf"
link_dotfile ".vimrc" ".vimrc"
link_dotfile ".config/starship.toml" ".config/starship.toml"
link_dotfile ".aliases" ".aliases"
link_dotfile ".vim" ".vim"
link_dotfile "nvim" ".config/nvim" 

echo "Linking process finished!"
if [ -d "$BACKUP_DIR" ]; then
  echo "Backups of overwritten files (if any) are in: $BACKUP_DIR"
else
  echo "No existing files needed backing up."
fi

exit 0
