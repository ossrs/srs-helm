#!/bin/bash

# Execute by: bash xxx.sh or bash zzz/yyy/xxx.sh or ./xxx.sh or ./zzz/yyy/xxx.sh source xxx.sh
REALPATH=$(realpath ${BASH_SOURCE[0]})
SCRIPT_DIR=$(cd $(dirname ${REALPATH}) && pwd)
WORK_DIR=$(cd $(dirname ${REALPATH})/.. && pwd)
echo "BASH_SOURCE=${BASH_SOURCE}, REALPATH=${REALPATH}, SCRIPT_DIR=${SCRIPT_DIR}, WORK_DIR=${WORK_DIR}"
cd ${WORK_DIR}

help=false
refresh=false

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help) help=true; shift ;;
        -refresh|--refresh) refresh=true; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
done

if [ "$help" = true ]; then
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -h, --help           Show this help message and exit"
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

git status |grep -q 'nothing to commit'
if [[ $? -ne 0 ]]; then
  echo "Failed: Please commit before release";
  exit 1
fi

git tag -d $REPO_TAG 2>/dev/null; git push origin :$REPO_TAG 2>/dev/null
git tag -d $SRS_SERVER_TAG 2>/dev/null; git push origin :$SRS_SERVER_TAG 2>/dev/null
echo "Delete tag OK: $REPO_TAG $SRS_SERVER_TAG"

git tag $REPO_TAG && git push origin $REPO_TAG
git tag $SRS_SERVER_TAG && git push origin $SRS_SERVER_TAG
echo "Publish OK: $REPO_TAG $SRS_SERVER_TAG"
echo "    https://github.com/ossrs/srs-helm/actions"
