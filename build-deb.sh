#!/bin/sh
# Builds dist/meetranslate_<version>_armel.deb from this tree (any Linux with dpkg-deb).
set -e
cd "$(dirname "$0")"
VERSION=$(sed -n 's/^Version: //p' packaging/control)
P=$(mktemp -d)
chmod 755 $P
A=$P/opt/meetranslate
mkdir -p $P/DEBIAN $A $P/usr/share/applications $P/usr/share/doc/meetranslate $P/usr/share/icons/hicolor/80x80/apps
cp packaging/control $P/DEBIAN/
cp src/main.py src/dictprep.py helper/meetranslate-fetch $A/
cp -r src/qml $A/
chmod 755 $A/meetranslate-fetch
cp packaging/meetranslate.desktop $P/usr/share/applications/
cp packaging/copyright $P/usr/share/doc/meetranslate/
cp src/meetranslate80.png $P/usr/share/icons/hicolor/80x80/apps/
(cd $P && find opt usr -type f -exec md5sum {} \; > DEBIAN/md5sums)
mkdir -p dist
dpkg-deb -Zgzip --root-owner-group -b $P dist/meetranslate_${VERSION}_armel.deb
rm -rf $P
