#!/bin/bash
# Helios GTK Theme Installer for Bazzite
# Usage: ./install.sh [--backup|--restore|--uninstall]

set -e

THEME_NAME="Helios"
BACKUP_FILE="$HOME/.config/helios-theme-backup.ini"

# Detect install method
get_share_dir() {
    if command -v brew &> /dev/null; then
        BREW_PREFIX=$(brew --prefix)
        echo "$BREW_PREFIX/share"
    else
        echo "/usr/share"
    fi
}

# Backup current theme
backup() {
    echo "💾 Backing up current GTK theme..."
    
    if command -v gsettings &> /dev/null; then
        mkdir -p "$HOME/.config"
        {
            echo "[gnome]"
            gsettings list-recursively org.gnome.desktop.interface | grep -E "(gtk-theme|icon-theme|color-scheme|font)" | while read -r key value; do
                key_name=$(echo "$key" | sed 's/.*\.//')
                echo "${key_name}=${value}"
            done
        } > "$BACKUP_FILE"
        echo "✅ Backup saved to $BACKUP_FILE"
    else
        echo "⚠️  gsettings not found, cannot backup"
    fi
}

# Restore theme
restore() {
    echo "♻️  Restoring backed up GTK theme..."
    
    if [ -f "$BACKUP_FILE" ]; then
        while IFS='=' read -r key value; do
            [ -z "$key" ] && continue
            case "$key" in
                gtk-theme) gsettings set org.gnome.desktop.interface gtk-theme "$value" ;;
                icon-theme) gsettings set org.gnome.desktop.interface icon-theme "$value" ;;
                color-scheme) gsettings set org.gnome.desktop.interface color-scheme "$value" ;;
                font-name) gsettings set org.gnome.desktop.interface font-name "$value" ;;
            esac
        done < "$BACKUP_FILE"
        echo "✅ Theme restored!"
    else
        echo "❌ No backup found at $BACKUP_FILE"
    fi
}

# Install theme
install() {
    local share_dir
    share_dir=$(get_share_dir)
    
    echo "🎨 Installing Helios GTK Theme..."
    
    # Backup first (auto-backup before install)
    backup
    
    # Install GTK theme
    echo "📂 Installing GTK theme to $share_dir/themes/"
    sudo mkdir -p "$share_dir/themes/Helios"
    sudo cp -r usr/share/themes/Helios/* "$share_dir/themes/Helios/"
    
    # Install fonts
    echo "📂 Installing fonts to $share_dir/fonts/"
    sudo mkdir -p "$share_dir/fonts/Helios"
    sudo cp -r usr/share/fonts/Helios/* "$share_dir/fonts/Helios/"
    
    # Refresh font cache
    echo "🔄 Refreshing font cache..."
    fc-cache -fv
    
    # Set GTK theme using gsettings (GNOME)
    echo "🎯 Setting GTK theme..."
    if command -v gsettings &> /dev/null; then
        gsettings set org.gnome.desktop.interface gtk-theme "Helios"
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
        gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
    fi
    
    echo "✅ Helios GTK Theme installed!"
    echo ""
    echo "💾 Your previous theme was backed up to: $BACKUP_FILE"
    echo "♻️  To restore later, run: ./install.sh --restore"
}

# Uninstall theme
uninstall() {
    local share_dir
    share_dir=$(get_share_dir)
    
    echo "🗑️  Uninstalling Helios GTK Theme..."
    
    sudo rm -rf "$share_dir/themes/Helios"
    sudo rm -rf "$share_dir/fonts/Helios"
    
    fc-cache -fv
    
    # Restore backup
    restore
    
    echo "✅ Helios removed and original theme restored!"
}

# Main
case "${1:-}" in
    --backup) backup ;;
    --restore) restore ;;
    --uninstall) uninstall ;;
    --help)
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  (none)     Install Helios GTK Theme"
        echo "  --backup  Save current GTK theme to backup file"
        echo "  --restore Restore backed up GTK theme"
        echo "  --uninstall Remove Helios and restore original"
        echo "  --help    Show this help"
        ;;
    *) install ;;
esac

echo ""
echo "Note: You may need to log out and back in for changes to fully apply."