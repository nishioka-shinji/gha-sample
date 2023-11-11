#!/bin/sh

SLACK_WEBHOOK_URL=$1
MESSAGE=$2

curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"${MESSAGE}\"}" $SLACK_WEBHOOK_URL
