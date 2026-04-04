# radiosh

A minimalist, lightning-fast terminal radio player written in pure Bash.

Features a searchable station database, favorite management, and Vim-style navigation.

![image](https://github.com/user-attachments/assets/7cf754f1-b1df-49b7-8327-63cff15bf162)

## Features

- **Online Search** — Instantly search thousands of stations via the Radio-Browser API
- **Favorites** — Save your favorite stations to a local M3U playlist
- **Vim-Style Navigation** — Use `h`, `j`, `k`, `l` to navigate menus (powered by fzf)
- **Popularity Sorting** — Online search results are automatically sorted by votes/popularity
- **Easy Installation** — Comes with a built-in installer for quick setup

## Prerequisites

- [fzf](https://github.com/junegunn/fzf) — Fuzzy finder for the interface
- [mpv](https://mpv.io/) — The engine that plays the audio stream
- [jq](https://stedolan.github.io/jq/) — To process API search results
- [curl](https://curl.se/) — To fetch station data

## Installation

Clone the repository:

```bash
git clone https://github.com/woodz-dot/sh-radio.git
cd sh-radio
```

Make the script executable:

```bash
chmod +x radiosh
```

Run the built-in installer:

```bash
./radiosh --install
```

This will copy the script to `~/.local/bin/radiosh`.

Update your PATH (if not already done):

**Bash/Zsh:**

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc  # or ~/.zshrc
```

**Fish:**

```bash
fish_add_path ~/.local/bin
```

## Usage

Simply type `radiosh` in your terminal to start:

```bash
radiosh
```

- Select a saved favorite to play immediately
- Select `__ONLINE_SEARCH__` to find new stations
- Press `y` after playing an online station to add it to your favorites

## Configuration

Favorites are stored as a standard M3U playlist at:

```
~/.config/mpv/radio.m3u
```

## License

MIT License — see [LICENSE](LICENSE) for details.
