#!/bin/sh
echo $BUILDER
case $BUILDER in
  docker | podman ) :;;
  *) BUILDER=docker
esac
if [ -z "$PLATFORM" ]
then
  PLATFORM=p10
#   echo "Environment variable PLATFORM is not defined"
#   exit 1
fi
if [ -z "$VERSION" ]
then
  VERSION=14
#   echo "Environment variable VERSION is not defined"
#   exit 1
fi

$BUILDER build  --build-arg VERSION=$VERSION --build-arg PLATFORM=$PLATFORM -t quay.io/altlinux/postgres$VERSION:$PLATFORM .
