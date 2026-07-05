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

// MARK: - Версия приложения
let appVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "0.0.0"

// MARK: - Self-update
// Скачивает свежий DMG с GitHub Releases, подменяет .app на месте и перезапускается.
final class UpdateManager {
    static let shared = UpdateManager()
    private let lock = NSLock()
    private var state = "idle"   // idle | downloading | installing | relaunching | error: …

    func getState() -> String { lock.lock(); defer { lock.unlock() }; return state }
    private func set(_ s: String) { lock.lock(); state = s; lock.unlock(); fputs("🔄 update: \(s)\n", stderr) }

    func start() {
        lock.lock()
        let busy = (state == "downloading" || state == "installing" || state == "relaunching")
        if !busy { state = "downloading" }
        lock.unlock()
        if busy { return }
        DispatchQueue.global(qos: .userInitiated).async { self.run() }
    }

    private func run() {
        let dmgURL = URL(string: "https://github.com/antonenkoo/airpods-head-tracker/releases/latest/download/AirPodsHeadTracker.dmg")!
        let tmpDMG = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("aht-update.dmg")
        do {
            let data = try Data(contentsOf: dmgURL)
            try? FileManager.default.removeItem(at: tmpDMG)
            try data.write(to: tmpDMG)
        } catch {
            set("error: download failed"); return
        }

        set("installing")
        let mount = NSTemporaryDirectory() + "aht-mount"
        _ = shell("/usr/bin/hdiutil", ["attach", tmpDMG.path, "-nobrowse", "-quiet", "-mountpoint", mount])
        let newApp = mount + "/AirPodsTracker.app"
        guard FileManager.default.fileExists(atPath: newApp) else {
            _ = shell("/usr/bin/hdiutil", ["detach", mount, "-quiet"])
            set("error: unexpected dmg contents"); return
        }

        let target = Bundle.main.bundlePath
        let backup = target + ".old"
        try? FileManager.default.removeItem(atPath: backup)
        do { try FileManager.default.moveItem(atPath: target, toPath: backup) }
        catch {
            _ = shell("/usr/bin/hdiutil", ["detach", mount, "-quiet"])
            set("error: cannot replace app"); return
        }
        let copied = shell("/usr/bin/ditto", [newApp, target]) == 0
        _ = shell("/usr/bin/hdiutil", ["detach", mount, "-quiet"])
        guard copied else {
            try? FileManager.default.removeItem(atPath: target)
            try? FileManager.default.moveItem(atPath: backup, toPath: target)
            set("error: install failed"); return
        }
        try? FileManager.default.removeItem(atPath: backup)
        try? FileManager.default.removeItem(at: tmpDMG)

        set("relaunching")
        // Новый инстанс запускаем, пока старый ещё жив: его сервер будет
        // ретраить занятый порт, а мы выходим секундой позже и порт освобождаем
        _ = shell("/usr/bin/open", ["-n", target])
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { exit(0) }
    }

    private func shell(_ cmd: String, _ args: [String]) -> Int32 {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: cmd); p.arguments = args
        p.standardOutput = FileHandle.nullDevice; p.standardError = FileHandle.nullDevice
        do { try p.run() } catch { return -1 }
        p.waitUntilExit()
        return p.terminationStatus
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
    private var listener: NWListener?
    private let port: UInt16

    init(port: UInt16) { self.port = port }

    // Порт может быть ещё занят предыдущим инстансом (self-update) — ретраим
    func start(attempts: Int = 20) {
        let params = NWParameters.tcp
        params.allowLocalEndpointReuse = true
        guard let l = try? NWListener(using: params, on: NWEndpoint.Port(rawValue: port)!) else {
            retry(attempts); return
        }
        listener = l
        l.stateUpdateHandler = { [weak self] state in
            if case .failed(let err) = state {
                fputs("⚠️  Порт \(self?.port ?? 0) занят (\(err)) — ретраю…\n", stderr)
                l.cancel()
                self?.retry(attempts)
            }
        }
        l.newConnectionHandler = { conn in
            conn.start(queue: .global())
            self.receive(on: conn)
        }
        l.start(queue: .global())
    }

    private func retry(_ attempts: Int) {
        guard attempts > 0 else {
            fputs("❌ Не удалось поднять сервер на порту \(port)\n", stderr)
            exit(1)
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            self.start(attempts: attempts - 1)
        }
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

            } else if path.hasPrefix("/api/app-info") {
                resp = httpResponse(status: "200 OK", contentType: "application/json",
                                    body: "{\"version\":\"\(appVersion)\"}".data(using: .utf8)!)

            } else if path.hasPrefix("/api/update-start") {
                UpdateManager.shared.start()
                resp = httpResponse(status: "200 OK", contentType: "application/json",
                                    body: "{\"ok\":true}".data(using: .utf8)!)

            } else if path.hasPrefix("/api/update-status") {
                let st = UpdateManager.shared.getState()
                    .replacingOccurrences(of: "\"", with: "'")
                resp = httpResponse(status: "200 OK", contentType: "application/json",
                                    body: "{\"state\":\"\(st)\"}".data(using: .utf8)!)

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
let server = HTTPServer(port: port)
server.start()
fputs("🌐 Интерфейс также доступен в браузере: http://localhost:\(port)\n", stderr)

let app = NSApplication.shared
let appDelegate = AppDelegate(port: port)
app.delegate = appDelegate
app.setActivationPolicy(.regular)
app.run()
