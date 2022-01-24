#!/bin/sh
VERSION=10
. ./.env
case $BUILDER in
  docker | podman ) :;;
  *) BUILDER=docker
esac
if [ -z "$PLATFORMS" ]
then
  PLATFORMS="p10 sisyphus"
fi

for PLATFORM in $PLATFORMS
do
  $BUILDER build \
	  --build-arg VERSION=$VERSION \
	  --build-arg PLATFORM=$PLATFORM \
	  -t $REGISTRY/altlinux/quaypostgres:$PLATFORM \
	  .
done
