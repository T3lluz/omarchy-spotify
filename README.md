# Omarchy theme for Spotify

A [Spicetify](https://spicetify.app) theme that makes the Spotify desktop app follow your [Omarchy](https://omarchy.org) setup. Switch Omarchy themes and Spotify switches with it. The music keeps playing, no restart.

It takes:

- colors from the current Omarchy theme's `colors.toml`, light themes included
- corner rounding from Hyprland's `decoration:rounding`, the same value the Omarchy shell reads. 0 gives square corners, 8 gives stock Spotify. The three panels, cards, menus and album art follow it.
- the font from `fc-match monospace`, which is what `omarchy font set` changes

Some details that hold on every theme:

- The window frame and the player bar use the theme's darkest background and the panels use the normal one, the way stock Spotify puts #121212 panels on black.
- The accent is pushed away from the background until it reads as text (4.5:1) where Spotify uses it as text, and to at least 3:1 where it's a fill like the play button. Text on accent fills picks the theme color, or black or white, that reads best.
- Error red, warning orange and info blue stay Spotify's own. They carry meaning, and plenty of themes have a grey "red".
- Page headers fade from the album color into the background. On light themes they fade through the theme's background instead of 60% black, which would leave a grey band.
- Menus get a 1px border instead of a blurred shadow, like Hyprland windows.

| Solitude | Tokyo Night |
|---|---|
| ![Solitude](screenshots/solitude.png) | ![Tokyo Night](screenshots/tokyo-night.png) |

Tested with Spotify 1.3.4 and Spicetify 2.46.4.

## Install

You need Spotify from the `spotify` package (in `/opt/spotify`) and Spicetify:

```sh
yay -S spicetify-bin
git clone https://github.com/T3lluz/omarchy-spotify.git
cd omarchy-spotify
./install.sh
```

The installer asks for root once. It makes your user the owner of `/opt/spotify`, since Spicetify patches files in there, and adds a pacman hook (below). Restart Spotify once afterwards. Every change after that applies live.

## What updates it

| Change | Trigger |
|---|---|
| `omarchy theme set` | `~/.config/omarchy/hooks/theme-set.d/spotify` |
| `omarchy font set` | `~/.config/omarchy/hooks/font-set.d/spotify` |
| Rounding changed in `looknfeel.lua` or another Hyprland config | `omarchy-spotify.service` reruns the sync on Hyprland's `configreloaded` event |
| A Spotify update | `/etc/pacman.d/hooks/spotify-spicetify.hook` takes `/opt/spotify` back and re-patches Spotify |

After a Spotify update, Spicetify sometimes needs a release of its own before it supports the new version. Until then the hook fails quietly and Spotify runs stock. Update Spicetify and run `omarchy-spotify-sync --reapply`.

## Settings

Optional, in `~/.config/omarchy/spotify.conf`:

```ini
font=all       # Omarchy font everywhere (default)
# font=none    # keep Spotify's fonts
rounding=yes   # "no" keeps Spotify's own corner radii
```

Run `omarchy-spotify-sync` after editing it.

## How it works

- `omarchy-spotify-sync` reads `colors.toml` and works out the palette in one awk pass. It writes `color.ini`, `user.css` and `theme.js` into `~/.config/spicetify/Themes/Omarchy`, then runs `spicetify refresh -n`, which copies them into Spotify without restarting it. Unchanged output is skipped, so a Hyprland reload doesn't touch Spotify.
- `user.css` sets Spotify's "encore" color tokens. Spotify defines them inside `@layer encore`, so plain rules outside the layer win without `!important`. The corner rules target the `Root__` panel classes and Spicetify's mapped class names, which survive Spotify updates.
- `theme.js` checks `user.css` every 1.5 seconds and reloads the theme stylesheets when it changes. It also rewrites the hardcoded `#0009` in page header gradients to a variable. Those rules only have hashed class names, so the script matches them by their gradient instead.
- `omarchy-spotify-watch` runs as a user service and listens on Hyprland's event socket for config reloads.

## Remove

```sh
./uninstall.sh
```

It restores stock Spotify, gives `/opt/spotify` back to root and drops the pacman hook. Spicetify stays installed.

## License

MIT
