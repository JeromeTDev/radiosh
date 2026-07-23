# radiosh

A minimalist, lightning-fast terminal radio player written in Bash.

Features a searchable station database, favorite management, and Vim-style navigation.

![image](https://github.com/user-attachments/assets/4f72d4eb-436f-470d-b2ff-f29aaaeed482)

## Features

- **Online Search** — Instantly search thousands of stations via the Radio-Browser API
- **Favorites** — Save your favorite stations to a local M3U playlist
- **Vim-Style Navigation** — Use `h`, `j`, `k`, `l` to navigate menus (powered by fzf)
- **Popularity Sorting** — Online search results are automatically sorted by votes/popularity
- **Easy Installation** — Comes with a built-in installer for quick setup

## Prerequisites

radiosh needs these tools at runtime:

- [fzf](https://github.com/junegunn/fzf) — Fuzzy finder for the interface
- [mpv](https://mpv.io/) — The engine that plays the audio stream
- [jq](https://stedolan.github.io/jq/) — To process API search results
- [curl](https://curl.se/) — To fetch station data

## Installation

Clone the repository:

```bash
git clone https://github.com/JeromeTDev/radiosh.git
cd radiosh
```

Make the script executable:

```bash
chmod +x radiosh
```

Run the built-in installer:

```bash
./radiosh --install
```

This validates the required dependencies and copies the script to `~/.local/bin/radiosh`.

If dependencies are missing, install them first with:

```bash
./radiosh --install-deps
```

Supported package managers for automatic dependency installation are `apt-get`, `dnf`, `pacman`, `zypper`, and `brew`.

If you prefer, you can also install the dependencies manually using your system package manager and then run `./radiosh --install` again.

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

## CLI Options

```text
radiosh --help
radiosh --install
radiosh --install-deps
```

- `--help` shows the available command-line options
- `--install` checks dependencies and installs `radiosh` to `~/.local/bin`
- `--install-deps` installs missing runtime dependencies using a supported package manager

## Configuration

Favorites are stored as tab-separated station names and stream URLs at:

```
~/.config/mpv/radio.m3u
```

Favorites written by older radiosh versions in `name | URL` format continue to work.

## License

MIT License — see [LICENSE](LICENSE) for details.
