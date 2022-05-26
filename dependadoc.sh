#!/bin/bash

set -eo pipefail

# working directory is $GITHUB_WORKSPACE
# docs folder at $GITHUB_WORKSPACE/docs
# working repo at $GITHUB_WORKSPACE/main

# env:
#   MIRRORED_FOLDER: ${{ inputs.mirrored-folder }}
#   MIRRORED_REPOSITORY_FULL_NAME: ${{ github.repository }}
#   DOCS_REPOSITORY_PATH: ${{ inputs.docs-repository-path}}
#   GITHUB_ACTOR: ${{ github.repository }}
#   GITHUB_WORKSPACE: ${{ github.workspace }}

# get mirrored repo name (no owner)
MIRRORED_REPO=$(echo ${MIRRORED_REPOSITORY_FULL_NAME##*/})

# set branch name
BRANCH_NAME=dependadoc-${MIRRORED_REPO}-$(date +%F-T%H-%M)

# create a new branch inside docs repo
git switch -c $BRANCH_NAME

# configure some settings
git config user.name $GITHUB_ACTOR
git config user.email via-github-actions@github.com

# copy files
echo "cp -a $GITHUB_WORKSPACE/main/$MIRRORED_FOLDER/.  $DOCS_REPOSITORY_PATH/mirror-${MIRRORED_REPO}/"
cp -a $GITHUB_WORKSPACE/main/$MIRRORED_FOLDER/.  $DOCS_REPOSITORY_PATH/mirror-${MIRRORED_REPO}/

# add changes
git add .

# generate file list
FILE_LIST=$(git status --porcelain)

# exit if file list indicates there are no changes
if [ -z "$FILE_LIST" ]; then 
  exit
fi

# commit the changes
git commit -m "Update ${MIRRORED_REPO}'s mirrored files"

# push the changes
git push --set-upstream origin $BRANCH_NAME

# open a PR
set +e # to allow EOF not to exit 1
read -r -d '' BODY <<EOF
The following files were modified:

$FILE_LIST
EOF

gh pr create \
  --title "Dependadoc PR from $MIRRORED_REPO (source ./$MIRRORED_FOLDER)" \
  --body "$BODY" \
  --fill
