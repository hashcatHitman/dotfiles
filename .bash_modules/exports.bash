#!/bin/bash

# Add personal bin directories to path if absent
if ! [[ "$PATH" == *"$HOME/.local/bin:$HOME/bin:"* ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Set JAVA_HOME
export JAVA_HOME=/usr/lib/jvm/java-latest-openjdk/

# Load cargo env
source "$HOME/.cargo/env"
