#!/bin/sh
# Install the wirelogd OpenRC service on Alpine Linux.
# Assumes the binary is already at /usr/local/sbin/wirelogd.
# Run as root from the repository root: sh contrib/openrc/install-alpine.sh
set -eu

here="$(cd "$(dirname "$0")" && pwd)"

if [ ! -x /usr/local/sbin/wirelogd ]; then
	echo "error: /usr/local/sbin/wirelogd not found or not executable" >&2
	exit 1
fi

# Service user
if ! getent group wirelogd >/dev/null 2>&1; then
	addgroup -S wirelogd
fi
if ! getent passwd wirelogd >/dev/null 2>&1; then
	adduser -S -D -H -h /var/run/wirelogd -s /sbin/nologin -G wirelogd wirelogd
fi

# Service files
install -Dm755 "$here/wirelogd.initd" /etc/init.d/wirelogd
[ -f /etc/conf.d/wirelogd ] || install -Dm644 "$here/wirelogd.confd" /etc/conf.d/wirelogd

# Default config (don't overwrite an existing one)
if [ ! -f /etc/wirelogd/config.json ]; then
	install -Dm644 "$here/../config.json" /etc/wirelogd/config.json
fi

rc-update add wirelogd default
rc-service wirelogd restart

echo "wirelogd installed; logs: /var/log/wirelogd/wirelogd.log"
