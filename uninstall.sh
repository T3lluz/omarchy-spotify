#!/bin/bash

# Removes everything install.sh added and puts Spotify back to stock.
# Spicetify itself stays installed.

systemctl --user disable --now omarchy-spotify.service 2>/dev/null
rm -f "$HOME/.config/systemd/user/omarchy-spotify.service" \
  "$HOME/.local/bin/omarchy-spotify-sync" \
  "$HOME/.local/bin/omarchy-spotify-watch" \
  "$HOME/.config/omarchy/hooks/theme-set.d/spotify" \
  "$HOME/.config/omarchy/hooks/font-set.d/spotify"
rm -rf "$HOME/.config/spicetify/Themes/Omarchy"
systemctl --user daemon-reload

if command -v spicetify >/dev/null; then
  spicetify -q config current_theme "" color_scheme "" >/dev/null 2>&1
  spicetify -q -n restore >/dev/null 2>&1
fi

# Hands /opt/spotify back to root and drops the pacman hook.
pkexec sh -c 'rm -f /etc/pacman.d/hooks/spotify-spicetify.hook; chown -R root:root /opt/spotify'

echo "Removed. Restart Spotify to load the stock look."
