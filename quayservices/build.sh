#!/bin/sh

cd postgres
echo "Создание образа postgres"
sh -x ./build.sh

cd ../redis
echo "Создание образа redis"
sh -x ./build.sh

cd quay
TMP=/tmp/quay_$$.tar
git checkout 162b79ec
echo "Создание образа quay"
sh -x ./build.sh
sudo podman save quay.io/quay/quay:162b79ec > $TMP
docker load < $TMP
rm -f $TMP

