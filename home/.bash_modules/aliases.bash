#!/bin/bash

# SPDX-FileCopyrightText: © 2026 hashcatHitman
#
# SPDX-License-Identifier: Apache-2.0 OR MIT

# Set the timezone offset to +0000 for git commands.
alias git='TZ=Etc/UTC git'

# `eza` how I like it.
#
# Display:
# -F does things like ending directories with `/` and sym links with `@`
# --icons auto tries to use icons from Nerd Fonts. Must be installed.
#
# Sorting:
# --group-directories-first lists directories first. Duh!
#
# Only applicable for eza -l (long view):
# -b shows file sizes with binary prefixes (KiB, etc)
# -h adds a header
# --smart-group only shows the group if the name is different than the owner
alias eza='eza -F -bh --group-directories-first --smart-group --icons auto'
