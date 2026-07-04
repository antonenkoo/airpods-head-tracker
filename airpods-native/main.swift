// AirPods head-tracking → локальный HTTP → браузер.
// Читает движения головы с AirPods (Pro/Max/3) через CMHeadphoneMotionManager
// и отдаёт углы Yaw/Pitch/Roll в веб-страницу с 3D-визуализацией.
//
// Требует macOS 14+ и наушников Apple с поддержкой Spatial Audio.
import Foundation
import CoreMotion
import Network
import AppKit

// MARK: - Хранилище последней ориентации (потокобезопасное)
final class OrientationStore {
    private let lock = NSLock()
    private var yaw = 0.0, pitch = 0.0, roll = 0.0
    private var lastUpdate: Date? = nil

    func update(y: Double, p: Double, r: Double) {
        lock.lock(); yaw = y; pitch = p; roll = r; lastUpdate = Date(); lock.unlock()
    }
    func json() -> Data {
        lock.lock(); defer { lock.unlock() }
        // connected — по свежести данных: наушники сняли/отключили → false,
        // подключили снова → true без перезапуска приложения
        let connected = lastUpdate.map { Date().timeIntervalSince($0) < 1.5 } ?? false
        let s = String(format: "{\"yaw\":%.2f,\"pitch\":%.2f,\"roll\":%.2f,\"connected\":%@}",
                       yaw, pitch, roll, connected ? "true" : "false")
        return s.data(using: .utf8)!
    }
}

let store = OrientationStore()

// MARK: - CoreMotion
let motionManager = CMHeadphoneMotionManager()

// Delegate: логируем подключение/отключение и перезапускаем сессию датчика,
// когда наушники появились уже после старта приложения
final class MotionDelegate: NSObject, CMHeadphoneMotionManagerDelegate {
    func headphoneMotionManagerDidConnect(_ manager: CMHeadphoneMotionManager) {
        fputs("🎧 Наушники подключились — стартую трекинг\n", stderr)
        beginMotionUpdates()
    }
    func headphoneMotionManagerDidDisconnect(_ manager: CMHeadphoneMotionManager) {
        fputs("🎧 Наушники отключились — жду следующего подключения\n", stderr)
    }
}
let motionDelegate = MotionDelegate()

private var motionCallbackCount = 0

func beginMotionUpdates() {
    let deg = 180.0 / Double.pi
    motionManager.startDeviceMotionUpdates(to: .main) { motion, error in
        if let error = error {
            fputs("⚠️  Ошибка датчика: \(error.localizedDescription)\n", stderr)
            return
        }
        guard let m = motion else { return }
        motionCallbackCount += 1
        if motionCallbackCount <= 3 || motionCallbackCount % 500 == 0 {
            fputs("📡 callback #\(motionCallbackCount): yaw=\(String(format:"%.1f",m.attitude.yaw*deg)) pitch=\(String(format:"%.1f",m.attitude.pitch*deg)) roll=\(String(format:"%.1f",m.attitude.roll*deg))\n", stderr)
        }
        store.update(y: m.attitude.yaw * deg,
                     p: m.attitude.pitch * deg,
                     r: m.attitude.roll * deg)
    }
}

func startMotion() {
    motionManager.delegate = motionDelegate
    let status = CMHeadphoneMotionManager.authorizationStatus()
    fputs("ℹ️  isDeviceMotionAvailable = \(motionManager.isDeviceMotionAvailable), доступ: \(status.rawValue) (0=не запрошен, 1=ограничен, 2=запрещён, 3=разрешён)\n", stderr)

    // Стартуем сразу — если наушников ещё нет, данные пойдут после подключения
    beginMotionUpdates()

    // Страховка: если сессия датчика не активна (наушники подключили позже,
    // BT-переподключение и т.п.) — перезапускаем каждые 3 секунды
    Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
        if !motionManager.isDeviceMotionActive {
            beginMotionUpdates()
        }
    }
}

// MARK: - Media & Volume (osascript bridge)

// Возвращает stdout osascript синхронно (вызывать только с фонового потока).
@discardableResult
func runScript(_ code: String) -> String {
    let proc = Process()
    let pipe = Pipe()
    proc.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
    proc.arguments = ["-e", code]
    proc.standardOutput = pipe
    proc.standardError = FileHandle.nullDevice
    do { try proc.run() } catch { return "" }
    proc.waitUntilExit()
    return String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?
        .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
}

func getVolume() -> Int {
    Int(runScript("output volume of (get volume settings)")) ?? 50
}

// Fire-and-forget: запускает osascript и НЕ ждёт завершения.
// Нужно для медиа-команд — иначе диалог Automation от macOS блокирует поток
// и браузер перестаёт получать свежие данные пока пользователь не нажмёт OK.
func runScriptFire(_ code: String) {
    DispatchQueue.main.async {
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        proc.arguments = ["-e", code]
        proc.standardOutput = FileHandle.nullDevice
        proc.standardError  = FileHandle.nullDevice
        proc.terminationHandler = { _ in }
        try? proc.run()
    }
}

// Проверка, запущено ли приложение (AppleScript `tell` сам запускает
// приложение, поэтому шлём команды только уже работающим плеерам)
func appRunning(_ bundleID: String) -> Bool {
    !NSRunningApplication.runningApplications(withBundleIdentifier: bundleID).isEmpty
}
let spotifyID = "com.spotify.client"
let musicID   = "com.apple.Music"

func mediaAction(_ action: String, level: Int? = nil) {
    switch action {
    case "next":
        // try/end try: молча игнорирует ошибку если приложение не отвечает
        if appRunning(spotifyID) { runScriptFire("try\ntell application \"Spotify\" to next track\nend try") }
        if appRunning(musicID)   { runScriptFire("try\ntell application \"Music\" to next track\nend try") }
    case "prev":
        if appRunning(spotifyID) { runScriptFire("try\ntell application \"Spotify\" to previous track\nend try") }
        if appRunning(musicID)   { runScriptFire("try\ntell application \"Music\" to previous track\nend try") }
    case "vol":
        if let v = level { runScriptFire("set volume output volume \(max(0, min(100, v)))") }
    default: break
    }
}

// MARK: - Минимальный HTTP-сервер
func httpResponse(status: String, contentType: String, body: Data) -> Data {
    var header = "HTTP/1.1 \(status)\r\n"
    header += "Content-Type: \(contentType)\r\n"
    header += "Content-Length: \(body.count)\r\n"
    header += "Cache-Control: no-store\r\n"
    header += "Connection: close\r\n\r\n"
    var d = header.data(using: .utf8)!
    d.append(body)
    return d
}

let htmlData = indexHTML.data(using: .utf8)!

// three.js из ресурсов бандла — отдаём по /three.module.min.js (работает офлайн)
let threeJSData: Data = {
    if let url = Bundle.main.url(forResource: "three.module.min", withExtension: "js"),
       let d = try? Data(contentsOf: url) {
        return d
    }
    fputs("⚠️  three.module.min.js не найден в Resources — куб не отрисуется\n", stderr)
    return Data()
}()

final class HTTPServer {
    private let listener: NWListener

    init(port: UInt16) throws {
        let params = NWParameters.tcp
        params.allowLocalEndpointReuse = true
        listener = try NWListener(using: params, on: NWEndpoint.Port(rawValue: port)!)
    }

    func start() {
        listener.newConnectionHandler = { conn in
            conn.start(queue: .global())
            self.receive(on: conn)
        }
        listener.start(queue: .global())
    }

    private func receive(on conn: NWConnection) {
        conn.receive(minimumIncompleteLength: 1, maximumLength: 8192) { data, _, _, error in
            defer { if error != nil { conn.cancel() } }
            guard let data = data,
                  let req = String(data: data, encoding: .utf8) else { conn.cancel(); return }

            let firstLine = req.split(separator: "\r\n").first.map(String.init) ?? ""
            let parts = firstLine.split(separator: " ")
            let path = parts.count > 1 ? String(parts[1]) : "/"

            let resp: Data
            if path.hasPrefix("/orientation") {
                resp = httpResponse(status: "200 OK", contentType: "application/json", body: store.json())

            } else if path.hasPrefix("/api/media") {
                let comps = URLComponents(string: "https://x" + path)
                let q = Dictionary(
                    (comps?.queryItems ?? []).map { ($0.name, $0.value ?? "") },
                    uniquingKeysWith: { f, _ in f }
                )
                let action = q["action"] ?? ""
                let level  = q["level"].flatMap(Int.init)
                // Запускаем осасрипт в фоне — не блокируем HTTP-поток
                DispatchQueue.global(qos: .userInitiated).async { mediaAction(action, level: level) }
                resp = httpResponse(status: "200 OK", contentType: "application/json",
                                    body: "{\"ok\":true}".data(using: .utf8)!)

            } else if path.hasPrefix("/three.module.min.js") {
                resp = httpResponse(status: "200 OK", contentType: "application/javascript", body: threeJSData)

            } else if path == "/api/players" {
                let s = appRunning(spotifyID), m = appRunning(musicID)
                resp = httpResponse(status: "200 OK", contentType: "application/json",
                                    body: "{\"spotify\":\(s),\"music\":\(m)}".data(using: .utf8)!)

            } else if path == "/api/vol-get" {
                // Блокирующий вызов: уже на фоновом потоке NW, ок
                let vol = getVolume()
                resp = httpResponse(status: "200 OK", contentType: "application/json",
                                    body: "{\"volume\":\(vol)}".data(using: .utf8)!)

            } else if path == "/" || path.hasPrefix("/index") {
                resp = httpResponse(status: "200 OK", contentType: "text/html; charset=utf-8", body: htmlData)

            } else {
                resp = httpResponse(status: "404 Not Found", contentType: "text/plain; charset=utf-8",
                                    body: "not found".data(using: .utf8)!)
            }
            conn.send(content: resp, completion: .contentProcessed { _ in conn.cancel() })
        }
    }
}

// MARK: - Запуск
let port: UInt16 = UInt16(ProcessInfo.processInfo.environment["PORT"] ?? "") ?? 8765
startMotion()
do {
    let server = try HTTPServer(port: port)
    server.start()
    fputs("🌐 Интерфейс также доступен в браузере: http://localhost:\(port)\n", stderr)
} catch {
    fputs("❌ Не удалось поднять сервер на порту \(port): \(error)\n", stderr)
    exit(1)
}

let app = NSApplication.shared
let appDelegate = AppDelegate(port: port)
app.delegate = appDelegate
app.setActivationPolicy(.regular)
app.run()
