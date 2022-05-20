#!/bin/bash
cd source/wireguard || exit 1
pkg_build.sh "$1"
git add . > /dev/null
git commit -m "Build"
git push
