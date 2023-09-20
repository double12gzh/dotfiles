bindkey  "^[[H"   beginning-of-line
bindkey  "^[[F"   end-of-line
bindkey  "^[[2~"  vi-insert
bindkey  "^[[3~"  delete-char
bindkey  "^A"     beginning-of-line
bindkey  "^E"     end-of-line
bindkey  "^P"     history-substring-search-up
bindkey  "^N"     history-substring-search-down
bindkey  "^R"     history-incremental-search-backward

# ctrl+left/rigth arrow: jump backward/forward
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# Edit line in vim with ctrl-o:
autoload edit-command-line; zle -N edit-command-line
bindkey '^o' edit-command-line

# help
# man zshzle
