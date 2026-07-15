#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok()   { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[x]${NC} $1"; }

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
)

for pkg in "${PACKAGES[@]}"; do
    if pacman -Qi "$pkg" &>/dev/null; then
        ok "$pkg (already installed)"
    elif sudo pacman -S --needed --noconfirm "$pkg" 2>/dev/null; then
        ok "$pkg installed"
    else
        warn "$pkg failed to install"
    fi
done

# ── Packages (AUR) ──
echo ""
echo "Installing AUR packages..."
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
    graphite-gtk-theme
    bibata-cursor-theme
)

for pkg in "${AUR_PACKAGES[@]}"; do
    if pacman -Qi "$pkg" &>/dev/null; then
        ok "$pkg (already installed)"
    elif yay -S --needed --noconfirm "$pkg" 2>/dev/null; then
        ok "$pkg installed"
    else
        warn "$pkg failed to install (is yay installed?)"
    fi
done

# ── 0xProto font (manual) ──
FONT_DIR="$HOME/.local/share/fonts"
if [ ! -f "$FONT_DIR/0xProto-Regular.ttf" ]; then
    warn "0xProto font not found."
    warn "Download from: https://github.com/nicholasgasior/gfonts-0xproto/releases"
    warn "Place in $FONT_DIR and run: fc-cache -fv"
else
    ok "0xProto font found"
fi

# ── Helper: copy config and replace __HOME__ ──
install_config() {
    local src="$1" dst="$2"
    mkdir -p "$dst"
    cp -r "$src"/* "$dst"/ 2>/dev/null || true
    find "$dst" -type f -not -name "*.jpg" -not -name "*.png" -not -name "*.gif" -not -name "*.so" -not -name "*.otf" -not -name "*.ttf" -exec sed -i "s|__HOME__|${HOME}|g" {} + 2>/dev/null || true
}

echo ""
echo "Installing configs..."

# ── DriftWM ──
install_config "$SCRIPT_DIR/driftwm" "$HOME/.config/driftwm"
ok "driftwm config"

# ── Chillpill-shell (bar) ──
install_config "$SCRIPT_DIR/chillpill-shell" "$HOME/.config/chillpill-shell"
ok "chillpill-shell (bar) config"

# ── Foot (terminal) ──
install_config "$SCRIPT_DIR/foot" "$HOME/.config/foot"
ok "foot (terminal) config"

# ── Fuzzel (launcher) ──
install_config "$SCRIPT_DIR/fuzzel" "$HOME/.config/fuzzel"
ok "fuzzel (launcher) config"

# ── Swaylock ──
install_config "$SCRIPT_DIR/swaylock" "$HOME/.config/swaylock"
ok "swaylock config"

# ── Fontconfig ──
install_config "$SCRIPT_DIR/fontconfig" "$HOME/.config/fontconfig"
ok "fontconfig (fonts fallback)"

# ── GTK3 ──
install_config "$SCRIPT_DIR/gtk-3.0" "$HOME/.config/gtk-3.0"
ok "GTK3 theme"

# ── GTK4 (no symlinks, copy real files) ──
install_config "$SCRIPT_DIR/gtk-4.0" "$HOME/.config/gtk-4.0"
# Recreate symlinks relative to Graphite-Dark-compact if installed
GRAPHITE_DIR="/usr/share/themes/Graphite-Dark-compact/gtk-4.0"
if [ -d "$GRAPHITE_DIR" ]; then
    ln -sf "$GRAPHITE_DIR/gtk.css" "$HOME/.config/gtk-4.0/gtk.css"
    ln -sf "$GRAPHITE_DIR/gtk-dark.css" "$HOME/.config/gtk-4.0/gtk-dark.css"
    ln -sf "$GRAPHITE_DIR/assets" "$HOME/.config/gtk-4.0/assets"
    ok "GTK4 symlinks (Graphite-Dark-compact)"
else
    rm -f "$HOME/.config/gtk-4.0/gtk.css" "$HOME/.config/gtk-4.0/gtk-dark.css" "$HOME/.config/gtk-4.0/assets"
    warn "Graphite-Dark-compact not found, broken symlinks removed"
fi
ok "GTK4 theme"

# ── Scripts ──
mkdir -p "$HOME/.local/bin"
cp "$SCRIPT_DIR/record-toggle.sh" "$HOME/.local/bin/record-toggle.sh"
chmod +x "$HOME/.local/bin/record-toggle.sh"
ok "record-toggle.sh"

# ── Avatar ──
if [ -f "$SCRIPT_DIR/pfp.jpg" ]; then
    cp "$SCRIPT_DIR/pfp.jpg" "$HOME/.pfp.jpg"
    ok "avatar (pfp.jpg)"
fi

# ── Wallpapers ──
if [ -d "$SCRIPT_DIR/Wallpaper" ]; then
    mkdir -p "$HOME/Pictures/Wallpaper"
    cp -r "$SCRIPT_DIR/Wallpaper/"* "$HOME/Pictures/Wallpaper/"
    ok "wallpapers"
fi

# ── Chillpill QML mods (sudo) ──
CHILLPILL_DIR="/usr/share/chillpill-shell"
CHILLPILL_MODS="$SCRIPT_DIR/chillpill-shell-mods"
if [ -d "$CHILLPILL_DIR" ] && [ -d "$CHILLPILL_MODS" ]; then
    echo ""
    warn "Installing chillpill-shell QML mods (sudo)..."
    sudo cp "$CHILLPILL_MODS/"*.qml "$CHILLPILL_DIR/"
    ok "chillpill QML modules"
fi

# ── fc-cache ──
fc-cache -fv >/dev/null 2>&1
ok "font cache updated"

echo ""
echo "=== Done! ==="
echo ""
echo "Re-login or reboot for all changes to take effect."
