########### Custom .zshrc ###############3

# https://direnv.net/docs/hook.html
eval "$(direnv hook zsh)"

# Aliases
# TODO: Fix antlr!
# alias antlr='java -jar /usr/local/lib/antlr-4.9.2-complete.jar'

# Env vars
export GO111MODULE=on
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
export CDR=$GOPATH/src/github.com/coder/coder
export EM=$GOPATH/src/github.com/Emyrk
export NAMESPACE=masley-dogfood

# Some node thing
export NODE_OPTIONS=--max-old-space-size=8192\

# Dark theme
export GTK_THEME=Adwaita:dark


##### Prompt settings
if [ ! -z ${ZSH+x} ];
then
  # ZSH prompt should be different
  exit 0
fi

. bash_functions.sh

host_color=36 # def blue at 36
branch_color=33 # def yellow at 33
if [ ! -z ${CODER_ENVIRONMENT_NAME+x} ];
then
  # In a coder env
  host_color=96
  branch_color=33
fi
####

# Custom ZSH Binds
bindkey '^ ' autosuggest-accept
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

bindkey  "^[[H"   beginning-of-line
bindkey  "^[[F"   end-of-line
bindkey  "^[[3~"  delete-char

# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
typeset -A ZSH_HIGHLIGHT_STYLES

# Default is all text not covered by the highligher
ZSH_HIGHLIGHT_STYLES[default]='fg=015'

# # Basic auto/tab complete:
# autoload -U compinit
# zstyle ':completion:*' menu select
# zmodload zsh/complist
# compinit
# _comp_options+=(globdots)               # Include hidden files.

# ============ BEGIN coder COMPLETION ============
_coder_completions() {
	local -a args completions
	args=("${words[@]:1:$#words}")
	completions=(${(f)"$(COMPLETION_MODE=1 "coder" "${args[@]}")"})
	compadd -a completions
}
compdef _coder_completions coder
# ============ END coder COMPLETION ==============
