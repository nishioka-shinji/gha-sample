#!/bin/bash
set -e

error_handler() {
    echo "エラーが発生したため処理を中断します。"
    exit 1
}

trap 'error_handler' ERR

BASE_REPO="$1"
NEW_REPO="${BASE_REPO}_schemafile"
BASE_PR_TITLE="$2"
BASE_PR_NUMBER="$3"
NEW_PR_TITLE="${BASE_PR_TITLE}（Schemafile切り出し）"

NEW_PR_BODY=$(cat <<EOF
#$BASE_PR_NUMBER のPRからSchemafileを切り出した対応です
EOF
)

git fetch
git checkout .

cat db/Schemafile > db/Schemafile_backup

git checkout main
git checkout -b $NEW_REPO

cat db/Schemafile_backup > db/Schemafile

# db/Schemafile の状態を確認
STATUS=$(git diff --quiet db/Schemafile)

if [ -z "$STATUS" ]; then
    echo "db/Schemafile に変更はありません。処理を中断します。"
    exit 0
fi

git add db/Schemafile
git config --global user.name 'github-actions[bot]'
git config --global user.email '41898282+github-actions[bot]@users.noreply.github.com'
git commit -m "Schemafile切り出し"
git push origin $NEW_REPO

gh pr create --base main --title "$NEW_PR_TITLE" --body "$NEW_PR_BODY"
