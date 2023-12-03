########### Custom .zshrc ###############3

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi


# Aliases
alias vi=vim
alias grep='grep --color'
# TODO: Fix antlr!
# alias antlr='java -jar /usr/local/lib/antlr-4.9.2-complete.jar'

# Env vars
export GO111MODULE=on
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
export CDR=$GOPATH/src/github.com/cdr
export EM=$GOPATH/src/github.com/Emyrk
export PATH=$PATH:$HOME/system/scripts
export NAMESPACE=masley-dogfood

# Some node thing
export NODE_OPTIONS=--max-old-space-size=8192


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