#!/bin/bash

BASE_REPO="$1"
NEW_REPO="${BASE_REPO}_schemafile"
BASE_PR_TITLE=$(gh pr view $BASE_REPO --json title -t "{{.title}}")
BASE_PR_NUMBER=$(gh pr view $BASE_REPO --json number -t "{{.number}}")
NEW_PR_TITLE="${BASE_PR_TITLE}（Schemafile切り出し）"

read -d '' NEW_PR_BODY << EOF
#$BASE_PR_NUMBER のPRからSchemafileを切り出した対応です
EOF

git fetch
git checkout $BASE_REPO

pbcopy < db/Schemafile

git checkout master
git pull
git checkout -b $NEW_REPO

pbpaste > db/Schemafile

git add db/Schemafile

git commit -m "Schemafile切り出し"
git push origin $NEW_REPO

gh pr create --assignee @me --base master --title "$NEW_PR_TITLE" --body "$NEW_PR_BODY"