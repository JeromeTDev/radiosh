#!/usr/bin/env bash
# Name: radiosh

# 1. Installations-Logik (Optionaler Aufruf via: ./radiosh --install)
if [[ "$1" == "--install" ]]; then
    DEST="$HOME/.local/bin/radiosh"
    mkdir -p "$(dirname "$DEST")"
    cp "$0" "$DEST"
    chmod +x "$DEST"
    echo "radiosh wurde nach $DEST kopiert."
    echo "Stelle sicher, dass $HOME/.local/bin in deinem PATH ist."
    exit 0
fi

# 2. Abhängigkeiten prüfen
for tool in fzf mpv jq curl; do
    if ! command -v "$tool" &> /dev/null; then
        echo "Fehler: '$tool' ist nicht installiert."
        exit 1
    fi
done

FAVORITES_FILE="$HOME/.config/mpv/radio.m3u"
mkdir -p "$(dirname "$FAVORITES_FILE")"
touch "$FAVORITES_FILE"

# FZF Optionen
FZF_OPTS=(
    --bind 'h:up,j:down,k:up,l:accept'
    --reverse
    --height 40%
    --ansi
)

# Hauptmenü
CHOICE=$( (
    cat "$FAVORITES_FILE"
    echo "__ONLINE_SEARCH__"
) | fzf --prompt="Wähle Sender oder Online-Suche: " "${FZF_OPTS[@]}")

# Abbruch bei ESC
[ -z "$CHOICE" ] && exit 0

if [ "$CHOICE" == "__ONLINE_SEARCH__" ]; then
    read -rp "Suchbegriff: " QUERY
    # Leerzeichen in URL encodieren
    QUERY_ENC=$(echo "$QUERY" | jq -sRr @uri)
    
    CHOICE=$(curl -s "https://de1.api.radio-browser.info/json/stations/search?name=$QUERY_ENC&limit=20" |
        jq -r 'sort_by(.votes) | reverse | .[] | "\(.name) | \(.url)"' |
        fzf --prompt="Online-Sender wählen: " "${FZF_OPTS[@]}")

    URL=$(echo "$CHOICE" | cut -d'|' -f2 | xargs)
    if [ -n "$URL" ]; then
        echo "Starte $CHOICE …"
        mpv "$URL"

        read -rp "In Favoriten speichern? (y/N) " RESP
        if [[ "$RESP" =~ ^[Yy]$ ]]; then
            grep -Fxq "$CHOICE" "$FAVORITES_FILE" || echo "$CHOICE" >>"$FAVORITES_FILE"
            echo "Hinzugefügt!"
        fi
    fi
else
    URL=$(echo "$CHOICE" | cut -d'|' -f2 | xargs)
    if [ -n "$URL" ]; then
        echo "Starte $CHOICE …"
        mpv "$URL"
    fi
fi
