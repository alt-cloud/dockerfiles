#!/bin/sh
. ./.env
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
  $BUILDER push $REGISTRY/altlinux/quaypostgres:$PLATFORM 
done
