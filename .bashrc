#!/bin/bash

# Source global definitions
if [ -f /etc/bashrc ]; then
    source /etc/bashrc
fi

# User specific environment
if [ -f "$HOME/.bash_modules/exports.bash" ]; then
    source "$HOME/.bash_modules/exports.bash"
fi

# User specific aliases
if [ -f "$HOME/.bash_modules/aliases.bash" ]; then
    source "$HOME/.bash_modules/aliases.bash"
fi

# Starship prompt
eval "$(starship init bash)"
