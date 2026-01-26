#!/bin/bash
set -e

distros=(
    # jammy
    noble
)

sed -i 's/quilt/native/' 'debian/source/format'

for distro in "${distros[@]}"; do
    ./utils/debian/update_changelog.sh "$distro"
    debuild --no-lintian -S --no-sign
done

sed -i 's/native/quilt/' 'debian/source/format'
