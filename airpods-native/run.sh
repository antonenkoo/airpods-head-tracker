#!/bin/bash
# Запускает бинарь напрямую (с выводом логов в терминал).
# Первый запуск может вызвать системный запрос на доступ к движению — разрешите.
cd "$(dirname "$0")"

# Убиваем все старые инстансы перед запуском
pkill -x AirPodsTracker 2>/dev/null; sleep 0.3

[ -x "AirPodsTracker.app/Contents/MacOS/AirPodsTracker" ] || ./build.sh
exec ./AirPodsTracker.app/Contents/MacOS/AirPodsTracker
