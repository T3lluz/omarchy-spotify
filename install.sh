#!/bin/bash

# Installs the Omarchy theme for Spotify. Run it again after editing any file here.
# Needs spicetify (aur/spicetify-bin) and Spotify installed in /opt/spotify.

set -euo pipefail
cd "$(dirname "$0")"

command -v spicetify >/dev/null || {
  echo "Install Spicetify first, for example: yay -S spicetify-bin" >&2
  exit 1
}
[[ -d /opt/spotify ]] || {
  echo "Spotify isn't in /opt/spotify. Install the spotify package first." >&2
  exit 1
}

install -Dm755 omarchy-spotify-sync "$HOME/.local/bin/omarchy-spotify-sync"
install -Dm755 omarchy-spotify-watch "$HOME/.local/bin/omarchy-spotify-watch"
install -Dm755 hook "$HOME/.config/omarchy/hooks/theme-set.d/spotify"
install -Dm755 hook "$HOME/.config/omarchy/hooks/font-set.d/spotify"
install -Dm644 omarchy-spotify.service "$HOME/.config/systemd/user/omarchy-spotify.service"

# Spicetify patches files in /opt/spotify, so your user needs to own it. The
# pacman hook restores that, and the patch, after every Spotify update.
pacman_hook=$(sed -e "s|@USER@|$USER|g" -e "s|@HOME@|$HOME|g" spotify-spicetify.hook.in)
if [[ $(stat -c %U /opt/spotify/Apps) != "$USER" ]] ||
  [[ $(cat /etc/pacman.d/hooks/spotify-spicetify.hook 2>/dev/null) != "$pacman_hook" ]]; then
  tmp=$(mktemp)
  printf '%s\n' "$pacman_hook" >"$tmp"
  pkexec sh -c "install -Dm644 '$tmp' /etc/pacman.d/hooks/spotify-spicetify.hook && chown -R '$USER:$USER' /opt/spotify"
  rm -f "$tmp"
fi

systemctl --user daemon-reload
systemctl --user enable --now omarchy-spotify.service
systemctl --user restart omarchy-spotify.service

"$HOME/.local/bin/omarchy-spotify-sync"

echo "Installed. Restart Spotify once if it was open, after that theme switches apply live."
