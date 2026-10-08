#!/bin/bash

# SPDX-FileCopyrightText: © 2026 hashcatHitman
#
# SPDX-License-Identifier: Apache-2.0 OR MIT

# Add personal bin directories to path if absent
if [[ "${PATH}" != *"${HOME}/.local/bin:${HOME}/bin:"* ]]; then
    PATH="${HOME}/.local/bin:${HOME}/bin:${PATH}"
fi
export PATH

# Place pycache files in home cache directory
export PYTHONPYCACHEPREFIX="${HOME}/.cache/__pycache__"

# Set JAVA_HOME
export JAVA_HOME=/usr/lib/jvm/java-latest-openjdk/

# Some applications respect this as a way to disable telemetry.
export DO_NOT_TRACK=1

# The GitHub CLI respects `DO_NOT_TRACK` at the time of writing. But just in
# case they remove support for some reason... this also disables telemetry for
# the GitHub CLI.
# https://docs.github.com/en/github-cli/github-cli/github-cli-telemetry#how-to-opt-out
export GH_TELEMETRY=0

# In theory, the extension respects the VSCodium telemetry setting. But... just
# in case.
#
# The .NET SDK telemetry feature is enabled by default for Microsoft
# distributions of the SDK. To opt out of the telemetry feature, set the
# `DOTNET_CLI_TELEMETRY_OPTOUT` environment variable to `1`` or `true`.
#
# The .NET SDK installer sends a single telemetry entry when a successful
# installation happens. To opt out, set the `DOTNET_CLI_TELEMETRY_OPTOUT`
# environment variable before you install the .NET SDK.
# https://learn.microsoft.com/en-us/dotnet/core/tools/telemetry?tabs=dotnet11#how-to-opt-out
export DOTNET_CLI_TELEMETRY_OPTOUT=1

# Load cargo env
# shellcheck disable=SC1091
source "${HOME}/.cargo/env"
