#!/usr/bin/env sh
set -eo pipefail

# Generate Twisted's plugin cache just before running -- all plugins should be
# installed at this point. Twisted is installed site-wide, so the root user is
# needed to perform this operation. See:
# http://twistedmatrix.com/documents/current/core/howto/plugin.html#plugin-caching
python -c 'from twisted.plugin import IPlugin, getPlugins; list(getPlugins(IPlugin))'

is_twistd_command() {
	local cmd="$1"; shift
	python - <<EOF
import sys
from twisted.plugin import getPlugins
from twisted.application.service import IServiceMaker
sys.exit(0 if '$cmd' in [p.tapname for p in getPlugins(IServiceMaker)] else 1)
EOF
}

env_vumi_opts() {
	env \
		| grep ^VUMI_OPT_ \
		| sed -e 's/^VUMI_OPT_//' -e 's/=/ /' \
		| awk '{printf("%s=%s:%s ", "--set-option", tolower($1), $2);}'
}

# If no args, first arg looks like an option, or first arg is a twistd command
if [ $# -eq 0 ] || [ "${1#-}" != "$1" ]; then
	set -- twistd --nodaemon --pidfile='' "${TWISTD_COMMAND:-vumi_worker}" "$@"
elif is_twistd_command "$1"; then
	set -- twistd --nodaemon --pidfile='' "$@"
fi

if [ "$1" = 'twistd' ]; then
	if [ -n "$WORKER_CLASS" ]; then
		set -- "$@" --worker-class "$WORKER_CLASS"
	fi

	if [ -n "$CONFIG_FILE" ]; then
		set -- "$@" --config "$CONFIG_FILE"
	fi

	if [ -n "$AMQP_HOST" ]; then
		set -- "$@" \
			--hostname "$AMQP_HOST" \
			--port "${AMQP_PORT:-5672}" \
			--vhost "${AMQP_VHOST:-/}" \
			--username "${AMQP_USERNAME:-guest}" \
			--password "${AMQP_PASSWORD:-guest}"
	fi

	if [ -n "$SENTRY_DSN" ]; then
		set -- "$@" --sentry "$SENTRY_DSN"
	fi

	set -- su-exec vumi "$@" $(env_vumi_opts)
fi

exec "$@"
