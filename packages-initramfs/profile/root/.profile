# ~/.profile: executed by Bourne-compatible login shells.

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    *-color) PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ ';;
    *)       PS1='\u@\h:\w\$ ';;
esac

# some more aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias vim='vi'

mesg n
