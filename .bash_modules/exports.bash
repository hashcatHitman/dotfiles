#!/bin/bash

# Add personal bin directories to path if absent
if ! [[ "$PATH" == *"$HOME/.local/bin:$HOME/bin:"* ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Place pycache files in home cache directory
export PYTHONPYCACHEPREFIX="$HOME/.cache/__pycache__"

# Set JAVA_HOME
export JAVA_HOME=/usr/lib/jvm/java-latest-openjdk/

# Some applications respect this as a way to disable telemetry.
export DO_NOT_TRACK=1

# Load cargo env
source "$HOME/.cargo/env"
