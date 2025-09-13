
#------------------------------------------------
# path
#------------------------------------------------

export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

export PATH="$(go env GOBIN):$PATH"
export PATH="$(asdf where nodejs)/bin:$PATH"
export PATH="$(asdf where rust)/bin:$PATH"

#------------------------------------------------
# alias
#------------------------------------------------

alias vim=hx
alias vi=hx
alias z=zellij

#------------------------------------------------
# func
#------------------------------------------------

rm() {
  command rm -i "$@"
}

#------------------------------------------------
# prompt
#------------------------------------------------
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[33m\]$(parse_git_branch)\[\033[00m\]\$ '

