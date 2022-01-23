#!/bin/sh
dir=`dirname ${BASH_SOURCE}[0]`
if [ -z "$dir" ]; then $dir=.; fi
VERSION=`basename $dir`
. $dir/../.env
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
