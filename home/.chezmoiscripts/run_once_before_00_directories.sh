#!/usr/bin/env bash

set -euo pipefail

# Create required directories
mkdir -p ~/bin ~/.local/bin ~/.local/share

# Ensure ~/bin is in PATH for this session
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"
