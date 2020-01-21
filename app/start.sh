#!/bin/bash

set -m

cd $(dirname $0)

if [[ -f ".env" ]]; then
	export $(egrep -v '^#' .env | xargs)
fi

if [[ ! -f "laravel-echo-server.json" ]]; then
	#
	# CONFIGURATION PARAMETERS
	#
	LARAVEL_ECHO_SERVER_DEBUG=${LARAVEL_ECHO_SERVER_DEBUG:-false}
	LARAVEL_ECHO_SERVER_AUTH_HOST=${LARAVEL_ECHO_SERVER_AUTH_HOST:-http://localhost}
	LARAVEL_ECHO_AUTH_ENDPOINT=${LARAVEL_ECHO_AUTH_ENDPOINT:-/broadcasting/auth}

	RAND_CLIENT_ID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
	RAND_CLIENT_KEY=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
	CLIENT_APP_ID=${CLIENT_APP_ID:-$RAND_CLIENT_ID}
	CLIENT_APP_KEY=${CLIENT_APP_KEY:-$RAND_CLIENT_KEY}

	DATABASE=${DATABASE:-sqlite}
	LARAVEL_ECHO_SERVER_REDIS_HOST=${LARAVEL_ECHO_SERVER_REDIS_HOST:-}

	if [[ "${LARAVEL_ECHO_SERVER_REDIS_HOST}" != "" ]]; then
		DATABASE=redis
	    LARAVEL_ECHO_SERVER_REDIS_PORT=${LARAVEL_ECHO_SERVER_REDIS_PORT:-6379}
	    DATABASE_CMD="del(.databaseConfig.sqlite) | .databaseConfig.redis.host=\"${LARAVEL_ECHO_SERVER_REDIS_HOST}\" | .databaseConfig.redis.port=${LARAVEL_ECHO_SERVER_REDIS_PORT} | .subscribers.redis=true"
		if [[ -n "${LARAVEL_ECHO_SERVER_REDIS_PASSWORD}" ]]; then
			DATABASE_CMD="${DATABASE_CMD} | .databaseConfig.redis.options.password=\"${LARAVEL_ECHO_SERVER_REDIS_PASSWORD}\""
		fi
		if [[ -n "${LARAVEL_ECHO_SERVER_REDIS_DB}" ]]; then
			DATABASE_CMD="${DATABASE_CMD} | .databaseConfig.redis.options.db=${LARAVEL_ECHO_SERVER_REDIS_DB}"
		fi
	else
	    sqlite3 server.sqlite "create table aTable(field1 int); drop table aTable;"
	    DATABASE_CMD='del(.databaseConfig.redis) | .subscribers.redis=false'
	fi

	LARAVEL_ECHO_SERVER_HOST=${LARAVEL_ECHO_SERVER_HOST:-0.0.0.0}
	LARAVEL_ECHO_SERVER_PORT=${LARAVEL_ECHO_SERVER_PORT:-6001}
	LARAVEL_ECHO_SERVER_PROTO=${LARAVEL_ECHO_SERVER_PROTO:-http}
	LARAVEL_ECHO_ALLOW_ORIGIN=${LARAVEL_ECHO_ALLOW_ORIGIN:-*}

	LARAVEL_ECHO_SERVER_SSL_CERT=${LARAVEL_ECHO_SERVER_SSL_CERT:-}
	LARAVEL_ECHO_SERVER_SSL_KEY=${LARAVEL_ECHO_SERVER_SSL_KEY:-}
	LARAVEL_ECHO_SERVER_SSL_CHAIN=${LARAVEL_ECHO_SERVER_SSL_CHAIN:-}

	#
	# CONFIGURATION MODIFIERS
	#
	jq -r ".authHost=\"$LARAVEL_ECHO_SERVER_AUTH_HOST\" | .authEndpoint=\"$LARAVEL_ECHO_AUTH_ENDPOINT\" |
	.clients[0].appId=\"$CLIENT_APP_ID\" | .clients[0].key=\"$CLIENT_APP_KEY\" |
	.database=\"$DATABASE\" | $DATABASE_CMD |
	.devMode=$LARAVEL_ECHO_SERVER_DEBUG | .host=\"$LARAVEL_ECHO_SERVER_HOST\" | .port=$LARAVEL_ECHO_SERVER_PORT | .protocol=\"$LARAVEL_ECHO_SERVER_PROTO\" |
	.sslCertPath=\"$LARAVEL_ECHO_SERVER_SSL_CERT\" | .sslKeyPath=\"$LARAVEL_ECHO_SERVER_SSL_KEY\" | .sslCertChainPath=\"$LARAVEL_ECHO_SERVER_SSL_CHAIN\" |
	.apiOriginAllow.allowOrigin=\"$LARAVEL_ECHO_ALLOW_ORIGIN\"" json.tmpl > laravel-echo-server.json

	echo " "
	echo "======================================================="
	echo "                CONFIGURATION DETAILS"
	echo "======================================================="
	echo " "
	echo " Host    : ${LARAVEL_ECHO_SERVER_HOST}"
	echo " Port    : ${LARAVEL_ECHO_SERVER_PORT}"
	echo " App ID  : ${CLIENT_APP_ID}"
	echo " App Key : ${CLIENT_APP_KEY}"
	echo " Auth    : ${LARAVEL_ECHO_SERVER_AUTH_HOST}${LARAVEL_ECHO_AUTH_ENDPOINT}"
	echo " "
	echo "======================================================="
	echo " https://github.com/tlaverdure/laravel-echo-server"
	echo " "
	echo " "
fi

if [[ "$LARAVEL_ECHO_SERVER_DEBUG" == true ]]; then
	export NPM_CONFIG_LOGLEVEL=info
fi

# Start the server
if [[ ! -f "laravel-echo-server.lock" ]]; then
	laravel-echo-server start
fi

exec "$@"
