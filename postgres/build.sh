#!/bin/sh

if [ $# -eq 0 ]
then
  VERSIONS="10 11 12 13 14"
else
  VERSIONS=$*
fi

for VERSION in $VERSIONS
do
  script="$VERSION/build.sh"
  if [ ! -f $script ]
  then
    echo "Версия $VERSION не поддерживается"
    continue
  fi
  sh -x ./$script
done
