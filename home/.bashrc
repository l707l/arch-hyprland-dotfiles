#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

# Add ~/.local/bin and deduplicate PATH
export PATH="/home/cian/.local/bin:$PATH"
export PATH="$(awk -v RS=: '!a[$0]++ {if (NR>1) printf(":"); printf("%s", $0)}' <<< "$PATH")"
