#!/bin/bash
set -e

BACKUP_DIR="$HOME/rice-backup"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok()   { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[x]${NC} $1"; }

if [ ! -d "$BACKUP_DIR" ]; then
    err "Backup folder not found: $BACKUP_DIR"
    exit 1
fi

echo ""
echo "=== DriftWM Rice Installer ==="
echo ""

# ── Packages (official) ──
echo "Installing packages..."
PACKAGES=(
    foot
    fuzzel
    grim
    slurp
    cliphist
    wl-clipboard
    brightnessctl
    playerctl
    pipewire
    pipewire-pulse
    pipewire-audio
    pipewire-alsa
    pipewire-jack
    gst-plugin-pipewire
    graphite-gtk-theme
    bibata-cursor-theme
)

for pkg in "${PACKAGES[@]}"; do
    if ! pacman -Qi "$pkg" &>/dev/null; then
        sudo pacman -S --needed --noconfirm "$pkg"
        ok "$pkg installed"
    else
        ok "$pkg already installed"
    fi
done

# ── Packages (AUR) ──
AUR_PACKAGES=(
    gpu-screen-recorder
    gpu-screen-recorder-gtk
    gpu-screen-recorder-ui
    gpu-screen-recorder-notification
    swaylock-effects
    otf-geist
    otf-geist-mono-nerd
    quickshell
    morewaita-icon-theme
    tela-circle-icon-theme-grey
)

for pkg in "${AUR_PACKAGES[@]}"; do
    if ! pacman -Qi "$pkg" &>/dev/null && ! yay -Qi "$pkg" &>/dev/null; then
        yay -S --needed --noconfirm "$pkg"
        ok "$pkg installed"
    else
        ok "$pkg already installed"
    fi
done

# ── 0xProto font (manual) ──
FONT_DIR="$HOME/.local/share/fonts"
if [ ! -f "$FONT_DIR/0xProto-Regular.ttf" ]; then
    warn "0xProto not found. Download from: https://github.com/nicholasgasior/gfonts-0xproto/releases"
    warn "Place fonts in $FONT_DIR and run: fc-cache -fv"
else
    ok "0xProto font found"
fi

# ── Copy configs ──
echo ""
echo "Installing configs..."

cp -r "$BACKUP_DIR/driftwm"        "$HOME/.config/driftwm"
ok "driftwm config"

cp -r "$BACKUP_DIR/chillpill-shell" "$HOME/.config/chillpill-shell"
ok "chillpill-shell (bar) config"

cp -r "$BACKUP_DIR/foot"           "$HOME/.config/foot"
ok "foot (terminal) config"

cp -r "$BACKUP_DIR/fuzzel"         "$HOME/.config/fuzzel"
ok "fuzzel (launcher) config"

cp -r "$BACKUP_DIR/swaylock"       "$HOME/.config/swaylock"
ok "swaylock config"

cp -r "$BACKUP_DIR/fontconfig"     "$HOME/.config/fontconfig"
ok "fontconfig (fonts fallback)"

mkdir -p "$HOME/.config/gtk-3.0"
cp -r "$BACKUP_DIR/gtk-3.0/"*     "$HOME/.config/gtk-3.0/"
ok "GTK3 theme"

mkdir -p "$HOME/.config/gtk-4.0"
cp -r "$BACKUP_DIR/gtk-4.0/"*     "$HOME/.config/gtk-4.0/"
ok "GTK4 theme"

# ── Scripts ──
mkdir -p "$HOME/.local/bin"
cp "$BACKUP_DIR/record-toggle.sh"  "$HOME/.local/bin/record-toggle.sh"
chmod +x "$HOME/.local/bin/record-toggle.sh"
ok "record-toggle.sh script"

# ── Avatar ──
if [ -f "$BACKUP_DIR/pfp.jpg" ]; then
    cp "$BACKUP_DIR/pfp.jpg" "$HOME/.pfp.jpg"
    ok "avatar (pfp.jpg)"
fi

# ── Chillpill bar QML files (if modified) ──
CHILLPILL_DIR="/usr/share/chillpill-shell"
CHILLPILL_MODS="$BACKUP_DIR/chillpill-shell-mods"
if [ -d "$CHILLPILL_DIR" ] && [ -d "$CHILLPILL_MODS" ]; then
    echo ""
    warn "Installing chillpill-shell QML mods (requires sudo)..."
    sudo cp "$CHILLPILL_MODS/"*.qml "$CHILLPILL_DIR/"
    ok "Chillpill QML modules installed"
fi

# ── GTK Catppuccin Mocha overlay ──
if [ ! -f "$HOME/.config/gtk-3.0/catppuccin-mocha.css" ]; then
    warn "Catppuccin Mocha CSS overlay missing — download from:"
    warn "  https://github.com/catppuccin/gtk/releases"
fi

echo ""
echo "=== Done! ==="
echo ""
echo "Next steps:"
echo "  1. Re-login or reboot for all changes to take effect"
echo "  2. If bar QML was modified, copy chillpill QML files with sudo"
echo "  3. Start driftwm from TTY or display manager"
