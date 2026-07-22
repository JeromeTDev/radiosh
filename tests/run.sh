#!/usr/bin/env bash

set -u

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TEST_TMP=$(mktemp -d)
trap 'rm -rf "$TEST_TMP"' EXIT

export HOME="$TEST_TMP/home"
export RADIOSH_FAVORITES_FILE="$TEST_TMP/favorites"
mkdir -p "$HOME"

# shellcheck disable=SC1091
source "$ROOT/radiosh"

failures=0

assert_equal() {
  local expected=$1
  local actual=$2
  local description=$3

  if [ "$expected" = "$actual" ]; then
    printf 'ok - %s\n' "$description"
  else
    printf 'not ok - %s\n  expected: %q\n  actual:   %q\n' \
      "$description" "$expected" "$actual"
    failures=$((failures + 1))
  fi
}

assert_status() {
  local expected=$1
  local description=$2
  shift 2

  "$@" >/dev/null 2>&1
  local actual=$?
  assert_equal "$expected" "$actual" "$description"
}

legacy=$(normalize_station_record '- 0 N - Chillout on Radio | https://example.test/live?x=a|b')
assert_equal $'- 0 N - Chillout on Radio\thttps://example.test/live?x=a|b' "$legacy" \
  'normalizes a leading-dash legacy favorite without losing URL pipes'

printf '%s\n' '- 0 N - Chillout on Radio | https://example.test/live?x=a|b' >"$FAVORITES_FILE"
assert_status 0 'finds an existing favorite whose name starts with a dash' \
  favorite_exists '- 0 N - Chillout on Radio' 'https://example.test/live?x=a|b'

output=$(add_favorite '- 0 N - Chillout on Radio' 'https://example.test/live?x=a|b')
assert_equal 'Already in favorites.' "$output" 'does not duplicate a legacy favorite'
assert_equal '1' "$(wc -l <"$FAVORITES_FILE")" 'keeps the favorites file unchanged for duplicates'

output=$(add_favorite 'New station' 'https://example.test/new')
assert_equal 'Added!' "$output" 'adds a new favorite'
assert_equal $'New station\thttps://example.test/new' "$(tail -n 1 "$FAVORITES_FILE")" \
  'writes new favorites in an unambiguous tab-separated format'

assert_status 1 'rejects an empty search before making a request' search_stations '   '
assert_status 1 'rejects malformed station records' normalize_station_record 'not a station'
assert_status 1 'rejects records with no URL' normalize_station_record $'Station\t'

assert_status 2 'rejects unknown command-line options' main '--wat'

FLOW_HOME="$TEST_TMP/flow-home"
FLOW_FAVORITES="$TEST_TMP/flow-favorites"
FLOW_OUTPUT=$(printf 'chill\ny\n' | env \
  HOME="$FLOW_HOME" \
  PATH="$ROOT/tests/fixtures:$PATH" \
  RADIOSH_FAVORITES_FILE="$FLOW_FAVORITES" \
  RADIOSH_FZF_STATE="$TEST_TMP/fzf-state" \
  RADIOSH_MPV_LOG="$TEST_TMP/mpv-log" \
  "$ROOT/radiosh" 2>&1)
FLOW_STATUS=$?

assert_equal '0' "$FLOW_STATUS" 'completes the online search, playback, and save flow'
assert_equal $'- 0 N - Chillout on Radio\thttps://example.test/live?x=a|b' \
  "$(cat "$FLOW_FAVORITES")" 'saves the selected station from the full flow'
assert_equal 'https://example.test/live?x=a|b' "$(cat "$TEST_TMP/mpv-log")" \
  'passes the complete stream URL to mpv'
if [[ "$FLOW_OUTPUT" == *'Added!'* ]]; then
  assert_equal 'present' 'present' 'confirms that the favorite was added'
else
  assert_equal 'present' 'missing' 'confirms that the favorite was added'
fi

INSTALL_DIR="$TEST_TMP/install/bin"
INSTALL_OUTPUT=$(env \
  HOME="$TEST_TMP/install-home" \
  PATH="$ROOT/tests/fixtures:$PATH" \
  RADIOSH_INSTALL_DIR="$INSTALL_DIR" \
  "$ROOT/radiosh" --install 2>&1)
INSTALL_STATUS=$?
assert_equal '0' "$INSTALL_STATUS" 'installs successfully when dependencies are available'
assert_status 0 'installs an executable script' test -x "$INSTALL_DIR/radiosh"
if [[ "$INSTALL_OUTPUT" == *'Successfully copied'* ]]; then
  assert_equal 'present' 'present' 'reports a successful install'
else
  assert_equal 'present' 'missing' 'reports a successful install'
fi

if [ "$failures" -gt 0 ]; then
  printf '\n%d test(s) failed.\n' "$failures"
  exit 1
fi

printf '\nAll tests passed.\n'
