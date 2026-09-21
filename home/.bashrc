#!/bin/bash

# SPDX-FileCopyrightText: © 2026 hashcatHitman
#
# SPDX-License-Identifier: Apache-2.0 OR MIT

# Globs will now also match hidden files.
shopt -s dotglob

# Globs will never match . or .., though.
shopt -s globskipdots

# Globs will now allow ** for recusrive matching.
shopt -s globstar

# Source global definitions
if [[ -f /etc/bashrc ]]; then
    # shellcheck disable=SC1091
    source /etc/bashrc
fi

# User specific environment
if [[ -f "${HOME}/.bash_modules/exports.bash" ]]; then
    # shellcheck source-path=home
    source "${HOME}/.bash_modules/exports.bash"
fi

# User specific aliases
if [[ -f "${HOME}/.bash_modules/aliases.bash" ]]; then
    # shellcheck source-path=home
    source "${HOME}/.bash_modules/aliases.bash"
fi

# Starship prompt
starship_ret="$(starship init bash)"
eval "${starship_ret}"
