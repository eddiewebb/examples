#!/bin/sh
set -e

# Workaround old docker images with incorrect $HOME
# check https://github.com/docker/docker/issues/2968 for details
if [ "${HOME}" = "/" ]
then
  export HOME=$(getent passwd $(id -un) | cut -d: -f6)
fi

echo "Replacing ssh repository URL $CIRCLE_REPOSITORY_URL with HTTPS version"
CIRCLE_REPOSITORY_URL="https://${CIRCLE_USERNAME}:${GH_ACCESS_TOKEN}@github.com/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}"

if [ -e "${CIRCLE_WORKING_DIRECTORY}/.git" ]
then
  cd ${CIRCLE_WORKING_DIRECTORY}
  git remote set-url origin "$CIRCLE_REPOSITORY_URL" || true
else
  mkdir -p ${CIRCLE_WORKING_DIRECTORY}
  cd ${CIRCLE_WORKING_DIRECTORY}
  git clone "$CIRCLE_REPOSITORY_URL" .
fi

if [ -n "$CIRCLE_TAG" ]
then
  git fetch --force origin "refs/tags/${CIRCLE_TAG}"
else
  git fetch --force origin "master:remotes/origin/master"
fi


if [ -n "$CIRCLE_TAG" ]
then
  git reset --hard "$CIRCLE_SHA1"
  git checkout -q "$CIRCLE_TAG"
elif [ -n "$CIRCLE_BRANCH" ]
then
  git reset --hard "$CIRCLE_SHA1"
  git checkout -q -B "$CIRCLE_BRANCH"
fi

git reset --hard "$CIRCLE_SHA1"
