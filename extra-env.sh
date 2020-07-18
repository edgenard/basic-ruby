#!/bin/sh

export CI=true
export CODEBUILD=true

export ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)

export GIT_BRANCH="$(git symbolic-ref HEAD --short 2>/dev/null)"
if [ "$GIT_BRANCH" = "" ] ; then
  echo "git symbolic-ref HEAD did not work"
  GIT_BRANCH="$(git branch -a --contains HEAD | sed -n 2p | awk '{ printf $1 }')";
  export GIT_BRANCH=${GIT_BRANCH#remotes/origin/};
fi

export GIT_CLEAN_BRANCH="$(echo $GIT_BRANCH | tr '/' '.')"
export GIT_ESCAPED_BRANCH="$(echo $GIT_CLEAN_BRANCH | sed -e 's/[]\/$*.^[]/\\\\&/g')"
export GIT_MESSAGE="$(git log -1 --pretty=%B)"
export GIT_AUTHOR="$(git log -1 --pretty=%an)"
export GIT_AUTHOR_EMAIL="$(git log -1 --pretty=%ae)"
export GIT_COMMIT="$(git log -1 --pretty=%H)"
export GIT_SHORT_COMMIT="$(git log -1 --pretty=%h)"
export GIT_TAG="$(git describe --tags --exact-match 2>/dev/null)"
export GIT_MOST_RECENT_TAG="$(git describe --tags --abbrev=0)"

export PULL_REQUEST=false
if [ "${GIT_BRANCH#pr-}" != "$GIT_BRANCH" ] ; then
  export PULL_REQUEST=${GIT_BRANCH#pr-};
fi

export PROJECT=${BUILD_ID%:$LOG_PATH}
export BUILD_URL=https://$AWS_DEFAULT_REGION.console.aws.amazon.com/codebuild/home?region=$AWS_DEFAULT_REGION#/builds/$BUILD_ID/view/new


echo "==> AWS CodeBuild Extra Environment Variables:"
echo "==> CI = $CI"
echo "==> CODEBUILD = $CODEBUILD"
echo "==> ACCOUNT_ID = $ACCOUNT_ID"
echo "==> GIT_AUTHOR = $GIT_AUTHOR"
echo "==> GIT_AUTHOR_EMAIL = $GIT_AUTHOR_EMAIL"
echo "==> GIT_BRANCH = $GIT_BRANCH"
echo "==> GIT_CLEAN_BRANCH = $GIT_CLEAN_BRANCH"
echo "==> GIT_ESCAPED_BRANCH = $GIT_ESCAPED_BRANCH"
echo "==> GIT_COMMIT = $GIT_COMMIT"
echo "==> GIT_SHORT_COMMIT = $GIT_SHORT_COMMIT"
echo "==> GIT_MESSAGE = $GIT_MESSAGE"
echo "==> GIT_TAG = $GIT_TAG"
echo "==> GIT_MOST_RECENT_TAG = $GIT_MOST_RECENT_TAG"
echo "==> PROJECT = $PROJECT"
echo "==> PULL_REQUEST = $PULL_REQUEST"
