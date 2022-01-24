#!/bin/sh
. ./.env

cd postgres
echo "Создание образа postgres"
postgresImage=$regNS/quay/postgres
sudo sh -x ./build.sh $postgresImage
sudo podman save $postgresImage | docker load


cd ../redis
redisImage=$regNS/quay/redis
echo "Создание образа redis"
sudo sh -x ./build.sh $redisImage
sudo podman save $redisImage | docker load

cd ../quay
quayImage=$regNS/quay/quay
git checkout $commitId
echo "Создание образа quay"
sudo sh -x ./build.sh
sudo podman tag quay/quay:$commitId $quayImage
sudo podman save $quayImage | docker load


