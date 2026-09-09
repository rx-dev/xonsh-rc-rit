# Interactive zsh conveniences.
autoload -Uz compinit
compinit
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS SHARE_HISTORY AUTO_PUSHD
bindkey -e
[[ -r "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"
[[ -r "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"
[[ -r "$HOME/.orbstack/shell/init.zsh" ]] && source "$HOME/.orbstack/shell/init.zsh"
(( $+commands[mise] )) && eval "$(mise activate zsh)"
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"
[[ "$TERM" != dumb ]] && (( $+commands[starship] )) && eval "$(starship init zsh)"
[[ -t 0 ]] && export GPG_TTY="$(tty)"
alias ll='ls -lAh'
alias ..='cd ..'
alias greps='grep -ri'
alias grepc='grep --color=always'
alias http-here='python3 -m http.server'
