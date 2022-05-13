#!/bin/bash
set -e

# the images to build (only build supported images by alpine, older images won't change anymore)
readonly versions="nophp 7.3 7.4 8.0"

# use buildkit
export DOCKER_BUILDKIT=1

# build the images
for vers in $versions; do
    docker build \
        --file Dockerfile-$vers \
        --pull \
        --no-cache \
        --progress=plain \
        --label "org.opencontainers.image.created=$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        --label "org.opencontainers.image.authors=Simon Frankenberger <simon-docker@fraho.eu>" \
        --label "org.opencontainers.image.url=https://github.com/bratkartoffel/apache-docker" \
        --label "org.opencontainers.image.source=$(git remote get-url origin)" \
        --label "org.opencontainers.image.revision=$(git log -1 --format=%H)" \
        --label "org.opencontainers.image.licenses=MIT" \
        --label "org.opencontainers.image.title=Apache webserver running on alpine in docker" \
        --label "org.opencontainers.image.base.name=$(grep -e ^FROM Dockerfile-$vers | awk '{print $2}')" \
        --tag bratkartoffel/web:$vers \
        --tag bratkartoffel/web:${vers%.*} \
        .
done

for i in $(docker images | grep -v '<none>' | grep -E '^bratkartoffel/web[[:space:]]+' | awk '{print $1 ":" $2}'); do
    docker push $i
done

