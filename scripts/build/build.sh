#!/bin/bash

#
#   This script is executed from within the container.
#

CCARMV7=arm-linux-gnueabihf-gcc
CCARM64=aarch64-linux-gnu-gcc
CCOSX64=/tmp/osxcross/target/bin/o64-clang
CCWIN64=x86_64-w64-mingw32-gcc
CCX64=/tmp/x86_64-centos6-linux-gnu/bin/x86_64-centos6-linux-gnu-gcc

GOPATH=/go
REPO_PATH=$GOPATH/src/github.com/grafana/grafana

cd /go/src/github.com/grafana/grafana
echo "current dir: $(pwd)"

if [ "$CIRCLE_TAG" != "" ]; then
  echo "Building releases from tag $CIRCLE_TAG"
  go run build.go -goarch armv7 -cc ${CCARMV7} -includeBuildNumber=false build
  go run build.go -goarch arm64 -cc ${CCARM64} -includeBuildNumber=false build
  go run build.go -goos darwin -cc ${CCOSX64} -includeBuildNumber=false build
  go run build.go -goos windows -cc ${CCWIN64} -includeBuildNumber=false build
  CC=${CCX64} go run build.go -includeBuildNumber=false build
else
  echo "Building incremental build for $CIRCLE_BRANCH"
  go run build.go -goarch armv7 -cc ${CCARMV7} build
  go run build.go -goarch arm64 -cc ${CCARM64} build
  go run build.go -goos darwin -cc ${CCOSX64} build
  go run build.go -goos windows -cc ${CCWIN64} build
  CC=${CCX64} go run build.go build
fi

yarn install --pure-lockfile --no-progress

source /etc/profile.d/rvm.sh

echo "current dir: $(pwd)"

if [ "$CIRCLE_TAG" != "" ]; then
  echo "Building frontend from tag $CIRCLE_TAG"
  go run build.go -buildNumber=${CIRCLE_BUILD_NUM} -includeBuildNumber=false build-frontend
  echo "Packaging a release from tag $CIRCLE_TAG"
  go run build.go -buildNumber=${CIRCLE_BUILD_NUM} -includeBuildNumber=false package latest
  go run build.go -goos linux -pkg-arch armv7 -buildNumber=${CIRCLE_BUILD_NUM} -includeBuildNumber=false package latest
  go run build.go -goos linux -pkg-arch arm64 -buildNumber=${CIRCLE_BUILD_NUM} -includeBuildNumber=false package latest
  go run build.go -goos darwin -pkg-arch amd64 -buildNumber=${CIRCLE_BUILD_NUM} -includeBuildNumber=false package latest
  go run build.go -goos windows -pkg-arch amd64 -buildNumber=${CIRCLE_BUILD_NUM} -includeBuildNumber=false package latest
else
  echo "Building frontend for $CIRCLE_BRANCH"
  go run build.go -buildNumber=${CIRCLE_BUILD_NUM} build-frontend
  echo "Packaging incremental build for $CIRCLE_BRANCH"
  go run build.go -buildNumber=${CIRCLE_BUILD_NUM} package latest
  go run build.go -goos linux -pkg-arch armv7 -buildNumber=${CIRCLE_BUILD_NUM} package latest
  go run build.go -goos linux -pkg-arch arm64 -buildNumber=${CIRCLE_BUILD_NUM} package latest
  go run build.go -goos darwin -pkg-arch amd64 -buildNumber=${CIRCLE_BUILD_NUM} package latest
  go run build.go -goos windows -pkg-arch amd64 -buildNumber=${CIRCLE_BUILD_NUM} package latest
fi
