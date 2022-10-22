#!/bin/bash

# Requirements:
# * docker
# * docker-compose

DOCKER_COMPOSE_PATH="./docker-compose.yml"

function finish() {
	STATUS=$?
	if [ "$STATUS" = "0" ]; then
		echo 'dev environment is now clean'
	else
		echo 'failed to clean dev environment'
	fi

	cd -
}

trap finish EXIT

cd "$(dirname "$0")"

docker-compose -f "$DOCKER_COMPOSE_PATH" down #--remove-orphans