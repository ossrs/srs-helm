#!/bin/bash

# Execute by: bash xxx.sh or bash zzz/yyy/xxx.sh or ./xxx.sh or ./zzz/yyy/xxx.sh source xxx.sh
REALPATH=$(realpath ${BASH_SOURCE[0]})
SCRIPT_DIR=$(cd $(dirname ${REALPATH}) && pwd)
WORK_DIR=$(cd $(dirname ${REALPATH})/.. && pwd)
echo "BASH_SOURCE=${BASH_SOURCE}, REALPATH=${REALPATH}, SCRIPT_DIR=${SCRIPT_DIR}, WORK_DIR=${WORK_DIR}"
cd ${WORK_DIR}

help=false
refresh=false
target=

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help) help=true; shift ;;
        -refresh|--refresh) refresh=true; shift ;;
        -target|--target) target="$2"; shift 2;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
done

if [ "$help" = true ]; then
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -h, --help           Show this help message and exit"
    echo "  -refresh, --refresh  Refresh current tag. Default: false"
    echo "  -target, --target    The target version to release, for example, v1.0.7"
    exit 0
fi

if [[ ! -z $target ]]; then
    RELEASE=$target
    refresh=yes
else
    RELEASE=$(git describe --tags --abbrev=0 --match oryx-v* |sed 's/oryx-//g')
fi
if [[ $? -ne 0 ]]; then echo "Release failed"; exit 1; fi

REVISION=$(echo $RELEASE |awk -F . '{print $3}')
if [[ $? -ne 0 ]]; then echo "Release failed"; exit 1; fi

let NEXT=$REVISION+1
if [[ $refresh == yes ]]; then
  let NEXT=$REVISION
fi
VERSION=$(echo $RELEASE |sed 's/v//g')
TAG=$RELEASE
echo "For oryx, RELEASE=$RELEASE, VERSION=$VERSION, TAG=$TAG, REVISION=$REVISION, NEXT=$NEXT"

if [[ $(grep -q "version: $VERSION" oryx/Chart.yaml || echo no) == no ]]; then
  VERSION0="sed -i '' 's/^version:.*/version: $VERSION/g' oryx/Chart.yaml"
  VERSION1="sed -i '' 's|v1.*/oryx|$TAG/oryx|g' oryx/Chart.yaml"
fi
if [[ ! -z $VERSION0 || ! -z $VERSION1 ]]; then
    echo "Please update version to $VERSION"
    if [[ ! -z $VERSION0 ]]; then echo "    $VERSION0 &&"; fi
    if [[ ! -z $VERSION1 ]]; then echo "    $VERSION1 &&"; fi
    echo "    echo ok"
    exit 1
fi

if [[ ! -f stable/oryx-$VERSION.tgz ]]; then
  echo "Failed: No package at stable/oryx-$VERSION.tgz"
  echo "Please run:"
  echo "    helm package oryx -d stable && \\"
  echo "    helm repo index stable"
  exit 1
fi

git st |grep -q 'nothing to commit'
if [[ $? -ne 0 ]]; then
  echo "Failed: Please commit before release";
  exit 1
fi

git fetch origin
if [[ $(git status |grep -q 'Your branch is up to date' || echo 'no') == no ]]; then
  git status
  echo "Failed: Please sync before release";
  exit 1
fi
echo "Sync OK"

git tag -d oryx-$TAG 2>/dev/null; git push origin :oryx-$TAG 2>/dev/null
echo "Delete tag OK: oryx-$TAG"

git tag oryx-$TAG && git push origin oryx-$TAG
echo "Publish OK: oryx-$TAG"

echo -e "\n\n"
echo "Chart oryx $VERSION ok, please release to official website by:"
echo "    ./auto/pub.sh"
