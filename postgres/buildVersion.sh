#!/bin/sh
dir=`dirname ${BASH_SOURCE}[0]`
if [ -z "$dir" ]; then $dir=.; fi
VERSION=`basename $dir`
. $dir/../.env
if [ ! -d $dir/root ]
then
  cp -r $dir/../root $dir/
fi
REGISTRY=quay.io
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
	  -f $dir/Dockerfile \
	  -t $REGISTRY/altlinux/postgres$VERSION:$PLATFORM \
	  $dir
done
