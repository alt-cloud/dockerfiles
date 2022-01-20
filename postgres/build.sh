#!/bin/sh

if [ -z "$PLATFORM" ]
then
  echo "Environment variable PLATFORM is not defined"
  exit 1
fi
if [ -z "$VERSION" ]
then
  echo "Environment variable VERSION is not defined"
  exit 1
fi

docker build  --build-arg VERSION=$VERSION --build-arg PLATFORM=$PLATFORM -t quay.io/altlinux/postgres$VERSION:$PLATFORM .
