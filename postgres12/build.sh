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

for PLATFORM in $PLATFORMS
do
  $BUILDER build $* \
	  --build-arg VERSION=$VERSION \
	  --build-arg PLATFORM=$PLATFORM \
	  -f $dir/Dockerfile \
	  -t $REGISTRY/altlinux/postgres$VERSION:$PLATFORM \
	  $dir
done
