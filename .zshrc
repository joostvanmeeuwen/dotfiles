eval "$(starship init zsh)"

bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word
bindkey "^[[1;3D" backward-word
bindkey "^[[1;3C" forward-word

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

export PATH=$PATH:$HOME/go/bin
