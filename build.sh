#!/bin/bash

# set -x
set -e

docker build --progress=plain -t heroku-buildpack-imagemagick-webp .
mkdir -p build

docker run --rm -t -v $PWD/build:/data heroku-buildpack-imagemagick-webp sh -c 'cp -f /usr/src/imagemagick/build/*.tar.gz /data/'
