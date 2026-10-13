[[ $- != *i* ]] && return

PS1='\[\e[38;2;61;255;116m\]❯\[\e[0m\] '
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias recon='matrix-recon'
alias rain='cmatrix -b -u 4 -C green'

# modern replacements, all following the green terminal palette
command -v eza >/dev/null && alias ls='eza --icons --group-directories-first' && alias ll='eza -la --icons --git --group-directories-first' && alias tree='eza --tree --icons'
command -v bat >/dev/null && alias cat='bat --paging=never'
command -v zoxide >/dev/null && eval "$(zoxide init bash --cmd cd)"
export EDITOR=nvim VISUAL=nvim
export FZF_DEFAULT_OPTS="--color=bg+:#0f3a1f,fg:#3dff74,fg+:#d9ffe6,hl:#b6ffcf,hl+:#d9ffe6,info:#2f6b45,prompt:#3dff74,pointer:#d9ffe6,marker:#8fdc5a,spinner:#3dff74,header:#1f8f45,border:#1f8f45 --border=rounded"
