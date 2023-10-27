#!/bin/bash

REALPATH=$(realpath $0)
WORK_DIR=$(cd $(dirname $REALPATH)/.. && pwd)
echo "Run pub at $WORK_DIR from $0"
cd $WORK_DIR

help=false
no_sync=false
refresh=false

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help) help=true; shift ;;
        -no-sync|--no-sync) no_sync=true; shift ;;
        -refresh|--refresh) refresh=true; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
done

if [ "$help" = true ]; then
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -h, --help           Show this help message and exit"
    echo "  -no-sync, --no-sync  Disable sync option. Default: false"
    echo "  -refresh, --refresh  Refresh current tag. Default: false"
    exit 0
fi

# The tags used for release:
#   repo tag: v1.0.123, automatically increase by each release.
#   chart srs-server tag: srs-server-v1.0.2, should match Chart.yaml, and updated manually.
REPO_RELEASE=$(git describe --tags --abbrev=0 --match v* 2>/dev/null || echo "v1.0.-1")
REPO_REVISION=$(echo $REPO_RELEASE|awk -F . '{print $3}')
let REPO_NEXT=$REPO_REVISION+1
if [[ $refresh == true && $REPO_REVISION != "-1" ]]; then
  let REPO_NEXT=$REPO_REVISION
fi
REPO_TAG="v1.0.$REPO_NEXT"
REPO_VERSION="1.0.$REPO_NEXT"
echo "repo: Last is $REPO_RELEASE $REPO_REVISION, release as NEXT:$REPO_NEXT TAG:$REPO_TAG VERION:$REPO_VERSION"

SRS_SERVER_PREFIX=srs-server
SRS_SERVER_RELEASE=$(git describe --tags --abbrev=0 --match ${SRS_SERVER_PREFIX}-v* 2>/dev/null || echo "${SRS_SERVER_PREFIX}-v1.0.-1")
SRS_SERVER_REVISION=$(echo $SRS_SERVER_RELEASE|awk -F . '{print $3}')
let SRS_SERVER_NEXT=$SRS_SERVER_REVISION+1
if [[ $refresh == true && $SRS_SERVER_REVISION != "-1" ]]; then
  let SRS_SERVER_NEXT=$SRS_SERVER_REVISION
fi
SRS_SERVER_TAG="${SRS_SERVER_PREFIX}-v1.0.$SRS_SERVER_NEXT"
SRS_SERVER_VERSION="1.0.$SRS_SERVER_NEXT"
echo "$SRS_SERVER_PREFIX: Last is $SRS_SERVER_RELEASE $SRS_SERVER_REVISION, release as NEXT:$SRS_SERVER_NEXT TAG:$SRS_SERVER_TAG VERSION:$SRS_SERVER_VERSION"

if [[ $(grep -q "version: $SRS_SERVER_VERSION" $SRS_SERVER_PREFIX/Chart.yaml || echo 'no') == no ]]; then
  echo "Failed: Please update Chart.yaml to version: $SRS_SERVER_VERSION"
  exit 1
fi
echo "Check $SRS_SERVER_PREFIX/Chart.yaml OK, version: $SRS_SERVER_VERSION"

CHARTS_HOME=stable
if [[ ! -f $CHARTS_HOME/$SRS_SERVER_PREFIX-$SRS_SERVER_VERSION.tgz ]]; then
  echo "Failed: No package at $CHARTS_HOME/$SRS_SERVER_PREFIX-$SRS_SERVER_VERSION.tgz"
  echo "Please run:"
  echo "    helm package $SRS_SERVER_PREFIX -d $CHARTS_HOME && \\"
  echo "    helm repo index $CHARTS_HOME"
  exit 1
fi

git status |grep -q 'nothing to commit'
if [[ $? -ne 0 ]]; then
  echo "Failed: Please commit before release";
  exit 1
fi

if [[ $no_sync == false ]]; then
  git fetch origin
  if [[ $(git status |grep -q 'Your branch is up to date' || echo 'no') == no ]]; then
    git status
    echo "Failed: Please sync before release";
    exit 1
  fi
  echo "Sync OK"
fi

git tag -d $REPO_TAG 2>/dev/null; git push origin :$REPO_TAG 2>/dev/null
git tag -d $SRS_SERVER_TAG 2>/dev/null; git push origin :$SRS_SERVER_TAG 2>/dev/null
echo "Delete tag OK: $REPO_TAG $SRS_SERVER_TAG"

git tag $REPO_TAG && git push origin $REPO_TAG
git tag $SRS_SERVER_TAG && git push origin $SRS_SERVER_TAG
echo "Publish OK: $REPO_TAG $SRS_SERVER_TAG"
echo "    https://github.com/ossrs/srs-helm/actions"
