#!/bin/bash
set -e

distro=${1:-noble}
version="$(git describe | sed 's/^v//;s/-/./;s/-/~/')~$distro"

sed -i "s/^set(copyq_version .*)$/set(copyq_version \"$version\")/" src/version.cmake
grep -Fq "\"$version\"" src/version.cmake

dch \
    -M \
    -v "$version" \
    -D "$distro" "from git commit $(git rev-parse HEAD)"

echo "To upload source code for $version run:"
echo "    debuild -S && dput ppa:hluk/copyq-beta ../copyq_${version}_source.changes"
