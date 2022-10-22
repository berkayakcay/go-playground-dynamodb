#!/bin/bash

# Requirements:
# * docker
# * docker-compose
# * nc
# * aws cli for migrations

DOCKER_COMPOSE_PATH="./docker-compose.yml"

function waitport() {
	echo "waiting for port $1"
	while ! nc -z localhost "$1"; do
		sleep 0.5
	done
	echo "port $1 is up"
}

function finish() {
	STATUS=$?
	if [ "$STATUS" != "0" ]; then
		docker-compose -f "$DOCKER_COMPOSE_PATH" down
	fi

	cd -
}

trap finish EXIT

cd "$(dirname "$0")"

docker-compose -f "$DOCKER_COMPOSE_PATH" up -d

waitport 8000

sleep 1

echo 'dev environment is now ready'