#!/bin/bash

BASE_REPO="$1"
NEW_REPO="${BASE_REPO}_schemafile"
BASE_PR_TITLE="$2"
BASE_PR_NUMBER="$3"
NEW_PR_TITLE="${BASE_PR_TITLE}（Schemafile切り出し）"

read -d '' NEW_PR_BODY << EOF
#$BASE_PR_NUMBER のPRからSchemafileを切り出した対応です
EOF

git fetch
git checkout $BASE_REPO

if [ $? -ne 0 ]; then
    echo "リポジトリ $BASE_REPO チェックアウト時にエラーが発生しました"
    exit 1
fi

SCHEMA=$(cat db/Schemafile)

git checkout master
git pull
git checkout -b $NEW_REPO

if [ $? -ne 0 ]; then
    echo "リポジトリ $NEW_REPO 作成時にエラーが発生しました"
    exit 1
fi

echo "$SCHEMA" > db/Schemafile

# git status を実行し、db/Schemafile の状態を確認
STATUS=$(git status db/Schemafile --porcelain)

if [ -z "$STATUS" ]; then
    echo "db/Schemafile に変更はありません。処理を中断します。"
    exit 0
fi

git add db/Schemafile

if [ $? -ne 0 ]; then
    echo "db/Schemafileの追加時にエラーが発生しました"
    exit 1
fi

git commit -m "Schemafile切り出し"
git push origin $NEW_REPO

gh pr create --assignee @me --base master --title "$NEW_PR_TITLE" --body "$NEW_PR_BODY"