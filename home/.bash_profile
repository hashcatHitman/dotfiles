#!/bin/bash

# Load .bashrc
if [[ -f "${HOME}/.bashrc" ]]; then
    # shellcheck source-path=home
    source "${HOME}/.bashrc"
fi
