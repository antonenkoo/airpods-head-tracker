#!/bin/bash
# Собирает AirPodsTracker.app из Swift-исходников.
# Обязательно .app-бандл + NSMotionUsageDescription + подпись — иначе macOS
# не выдаст TCC-разрешение на доступ к движению наушников.
# Xcode не нужен: достаточно Command Line Tools (swiftc, iconutil, sips).
set -e
cd "$(dirname "$0")"

VERSION="1.2.0"
APP="AirPodsTracker.app"
BIN_DIR="$APP/Contents/MacOS"
RES_DIR="$APP/Contents/Resources"
BIN="$BIN_DIR/AirPodsTracker"

echo "🧹 Чищу старую сборку…"
rm -rf "$APP"
mkdir -p "$BIN_DIR" "$RES_DIR"

echo "🎨 Генерирую иконку…"
if [ ! -f AppIcon.icns ]; then
  swift gen-icon.swift AppIcon.png
  ICONSET="AppIcon.iconset"
  rm -rf "$ICONSET"; mkdir "$ICONSET"
  for s in 16 32 128 256 512; do
    sips -z $s $s AppIcon.png --out "$ICONSET/icon_${s}x${s}.png" >/dev/null
    d=$((s*2))
    sips -z $d $d AppIcon.png --out "$ICONSET/icon_${s}x${s}@2x.png" >/dev/null
  done
  iconutil -c icns "$ICONSET" -o AppIcon.icns
  rm -rf "$ICONSET" AppIcon.png
fi
cp AppIcon.icns "$RES_DIR/AppIcon.icns"

echo "🔨 Компилирую Swift…"
swiftc -O main.swift html.swift app.swift -o "$BIN" \
  -framework CoreMotion -framework Network -framework Foundation \
  -framework AppKit -framework WebKit

echo "📝 Пишу Info.plist…"
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key>            <string>AirPodsTracker</string>
  <key>CFBundleDisplayName</key>     <string>AirPods Head Tracker</string>
  <key>CFBundleIdentifier</key>      <string>com.mark.airpodstracker</string>
  <key>CFBundleVersion</key>         <string>$VERSION</string>
  <key>CFBundleShortVersionString</key> <string>$VERSION</string>
  <key>CFBundleExecutable</key>      <string>AirPodsTracker</string>
  <key>CFBundlePackageType</key>     <string>APPL</string>
  <key>CFBundleIconFile</key>        <string>AppIcon</string>
  <key>LSMinimumSystemVersion</key>  <string>14.0</string>
  <key>NSHighResolutionCapable</key> <true/>
  <key>NSMotionUsageDescription</key>
  <string>Чтение движений головы с AirPods для визуализации ориентации.</string>
  <key>NSBluetoothAlwaysUsageDescription</key>
  <string>Связь с AirPods для получения данных о движении.</string>
  <key>NSAppTransportSecurity</key>
  <dict>
    <key>NSAllowsLocalNetworking</key> <true/>
  </dict>
</dict>
</plist>
PLIST

echo "✍️  Ad-hoc подпись…"
codesign --force --sign - --identifier com.mark.airpodstracker "$APP"

echo ""
echo "✅ Готово: $APP (v$VERSION)"
echo "   Запуск:  open $APP"
