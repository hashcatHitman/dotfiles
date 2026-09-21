#!/bin/bash

# SPDX-FileCopyrightText: © 2026 hashcatHitman
#
# SPDX-License-Identifier: Apache-2.0 OR MIT

# Load .bashrc
if [[ -f "${HOME}/.bashrc" ]]; then
    # shellcheck source-path=home
    source "${HOME}/.bashrc"
fi
