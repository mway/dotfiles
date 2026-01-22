#!/usr/bin/env bash

set -euo pipefail

MISE_BIN="$HOME/bin/mise"
MISE_CONFIG="$HOME/.config/mise"

# Ensure PATH includes ~/bin
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

echo "→ Installing Mise-managed tools..."

# Install all tools from config
"$MISE_BIN" install --yes || {
    echo "⚠️  Some tools failed to install"
    echo "You can retry with: mise install"
}

# Upgrade tools if this isn't the first run
if [[ -f "$HOME/.local/share/mise/installs/.installed" ]]; then
    echo "→ Upgrading Mise-managed tools..."
    "$MISE_BIN" upgrade --yes || {
        echo "⚠️  Some upgrades failed"
        echo "You can retry with: mise upgrade"
    }
fi

# Mark installation complete
mkdir -p "$HOME/.local/share/mise/installs"
touch "$HOME/.local/share/mise/installs/.installed"

echo "✓ Mise tool installation complete"
