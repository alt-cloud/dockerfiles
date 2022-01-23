#!/bin/sh
dir=`dirname ${BASH_SOURCE}[0]`
. $dir/.env
REGISTRY=quay.io
case $BUILDER in
  docker | podman ) :;;
  *) BUILDER=docker
esac
if [ -z "$PLATFORM" ]
then
  PLATFORMS="p10 sisyphus"
fi
$BUILDER login $REGISTRY

for PLATFORM in $PLATFORMS
do
  $BUILDER push $REGISTRY/altlinux/postgres$VERSION:$PLATFORM
done
