#!/bin/bash
set -e

error_handler() {
    echo "エラーが発生したため処理を中断します。エラー発生箇所: $BASH_COMMAND"
    exit 1
}

trap 'error_handler' ERR

BASE_HEAD_REF="$1"
BASE_PR_TITLE="$2"
BASE_PR_NUMBER="$3"
NEW_HEAD_REF="${BASE_HEAD_REF}_schemafile"
NEW_PR_TITLE="${BASE_PR_TITLE}（Schemafile切り出し）"
NEW_PR_BODY=$(cat <<EOF
#$BASE_PR_NUMBER のPRからSchemafileを切り出した対応です
EOF
)

BRANCH_IS_EXISTING=$(
    git fetch origin $NEW_HEAD_REF &&
    echo true ||
    echo false
)

PR_LIST=$(
    gh pr list --search "head:$NEW_HEAD_REF" --json headRefName --jq ".[] | select(.headRefName == \"$NEW_HEAD_REF\")"
)

echo $PR_LIST

git branch --contains
# 余計なdiffがあると、ブランチ切り替え時にエラーになるため、一旦全ての変更を破棄する
git checkout .

cat db/Schemafile > db/Schemafile_backup

git fetch origin main
git checkout main

git branch --contains

if [ "$BRANCH_IS_EXISTING" = true ]; then
    git checkout $NEW_HEAD_REF
else
    git checkout -b $NEW_HEAD_REF
fi

cat db/Schemafile_backup > db/Schemafile

STATUS=$(git status db/Schemafile --porcelain)

if [ -z "$STATUS" ]; then
    echo "db/Schemafile に変更はありません。処理を中断します。"
    exit 0
fi

git add db/Schemafile
git config --global user.name 'github-actions[bot]'
git config --global user.email '41898282+github-actions[bot]@users.noreply.github.com'
git commit -m "Schemafile切り出し"
git push origin $NEW_HEAD_REF


if [ -z "$PR_LIST" ]; then
    echo "PR作成済み。処理を中断します。"
    exit 0
fi

gh pr create --base main --title "$NEW_PR_TITLE" --body "$NEW_PR_BODY"
