#!/bin/bash

# Set the timezone offset to +0000 for git commands.
alias git='TZ=UTC0 git'

# `eza` how I like it.
#
# Display:
# -F does things like ending directories with `/` and sym links with `@`
#
# Sorting:
# --group-directories-first lists directories first. Duh!
#
# Only applicable for eza -l (long view):
# -b shows file sizes with binary prefixes (KiB, etc)
# -h adds a header
# --smart-group only shows the group if the name is different than the owner
alias eza='eza -F -bh --group-directories-first --smart-group'
