#!/bin/bash
# Упаковывает AirPodsTracker.app в DMG для распространения.
# Требует предварительной сборки: ./build.sh
set -e
cd "$(dirname "$0")"

VERSION="1.0.0"
APP="AirPodsTracker.app"
DMG="AirPodsHeadTracker-$VERSION.dmg"
STAGE="dmg-stage"

[ -d "$APP" ] || { echo "❌ Сначала собери приложение: ./build.sh"; exit 1; }

echo "📦 Готовлю содержимое DMG…"
rm -rf "$STAGE" "$DMG"
mkdir "$STAGE"
cp -R "$APP" "$STAGE/"
ln -s /Applications "$STAGE/Applications"

echo "💿 Создаю $DMG…"
hdiutil create -volname "AirPods Head Tracker" \
  -srcfolder "$STAGE" -ov -format UDZO "$DMG" >/dev/null
rm -rf "$STAGE"

echo "✅ Готово: $DMG ($(du -h "$DMG" | cut -f1 | xargs))"
