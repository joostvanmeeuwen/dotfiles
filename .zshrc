eval "$(starship init zsh)"

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word
bindkey "^[[1;3D" backward-word
bindkey "^[[1;3C" forward-word
bindkey '\e[3;5~' kill-word  # Ctrl + Delete
bindkey '\e[3;3~' kill-word  # Alt + Delete
bindkey '\e\x7f' backward-kill-word

# Home
if [[ -n "${terminfo[khome]}" ]]; then
  bindkey -- "${terminfo[khome]}" beginning-of-line
else
  bindkey -- '\e[H' beginning-of-line
  bindkey -- '\e[1~' beginning-of-line
  bindkey -- '\e[7~' beginning-of-line
fi

# End
if [[ -n "${terminfo[kend]}" ]]; then
  bindkey -- "${terminfo[kend]}" end-of-line
else
  bindkey -- '\e[F' end-of-line
  bindkey -- '\e[4~' end-of-line
  bindkey -- '\e[8~' end-of-line
fi

# Delete
if [[ -n "${terminfo[kdch1]}" ]]; then
  bindkey -- "${terminfo[kdch1]}" delete-char
else
  bindkey -- '\e[3~' delete-char
fi

if [ -f ~/.aliases ]; then
    . ~/.aliases
fi

if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
  tmux list-sessions > /dev/null 2>&1

  if [ $? -eq 0 ]; then
    tmux attach || tmux new-session
  else
    tmux new-session
  fi
fi

source ~/.zsh/.zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# pnpm
export PNPM_HOME="/home/joost/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
#

source <(fzf --zsh)

export PATH="$HOME/.local/bin:$HOME/go/bin:$PATH"
