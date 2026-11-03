#!/bin/sh
# Starts as root, sets up volumes and drops privileges afterwards.
# This ensures bind mounts owned by host root work without manual chown.
set -e

PUID="${PUID:-10001}"
PGID="${PGID:-10001}"
DATA_DIR="${APP_DATA_DIR:-/data}"
OUT_DIR="${SCAN_OUTPUT_DIR:-/scans}"

if [ "$(id -u)" != "0" ]; then
    # Already started unprivileged (e.g. via "user:" in Compose):
    # nothing to adjust, continue directly.
    exec "$@"
fi

if [ "$(id -u scanner)" != "$PUID" ]; then
    usermod -o -u "$PUID" scanner
fi
if [ "$(id -g scanner)" != "$PGID" ]; then
    groupmod -o -g "$PGID" scanner
fi

for dir in "$DATA_DIR" "$OUT_DIR"; do
    mkdir -p "$dir" 2>/dev/null || true
    if [ ! -d "$dir" ]; then
        echo "ScanDeck: $dir could not be created." >&2
        continue
    fi
    # Only touch permissions if needed: saves time with many scans.
    if [ "$(stat -c %u "$dir")" != "$PUID" ] || [ "$(stat -c %g "$dir")" != "$PGID" ]; then
        chown -R "$PUID:$PGID" "$dir" 2>/dev/null \
            || echo "ScanDeck: Failed to set owner for $dir; please check permissions on host." >&2
    fi
    if ! su scanner -s /bin/sh -c "test -w '$dir'"; then
        echo "ScanDeck: $dir is not writable by the service (UID $PUID)." >&2
    fi
done

exec setpriv --reuid="$PUID" --regid="$PGID" --init-groups --inh-caps=-all "$@"
