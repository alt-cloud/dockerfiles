#!/bin/sh
image=$1
podman build -t $image .
