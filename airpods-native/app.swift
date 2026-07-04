// Нативное окно приложения: NSWindow + WKWebView с интерфейсом,
// который сервер отдаёт на http://localhost:<port>/.
// UI остаётся единым для окна и браузера — WebView просто грузит localhost.
import AppKit
import WebKit

final class AppDelegate: NSObject, NSApplicationDelegate, WKNavigationDelegate {
    private let port: UInt16
    private var window: NSWindow!
    private var webView: WKWebView!

    init(port: UInt16) {
        self.port = port
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        buildMenu()

        let config = WKWebViewConfiguration()
        // Медиа-жесты и куб не требуют пользовательского клика для анимаций
        config.mediaTypesRequiringUserActionForPlayback = []

        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.underPageBackgroundColor = NSColor(srgbRed: 0.07, green: 0.07, blue: 0.07, alpha: 1)

        let rect = NSRect(x: 0, y: 0, width: 1100, height: 760)
        window = NSWindow(contentRect: rect,
                          styleMask: [.titled, .closable, .miniaturizable, .resizable],
                          backing: .buffered, defer: false)
        window.title = "AirPods Head Tracker"
        window.minSize = NSSize(width: 420, height: 520)
        window.backgroundColor = NSColor(srgbRed: 0.07, green: 0.07, blue: 0.07, alpha: 1)
        window.contentView = webView
        window.center()
        window.setFrameAutosaveName("MainWindow")
        window.makeKeyAndOrderFront(nil)

        webView.load(URLRequest(url: URL(string: "http://localhost:\(port)/")!))
        NSApp.activate(ignoringOtherApps: true)
    }

    // Сервер стартует параллельно с окном — если WebView успел раньше, пробуем ещё раз
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        retryLoad()
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        retryLoad()
    }
    private func retryLoad() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self else { return }
            self.webView.load(URLRequest(url: URL(string: "http://localhost:\(self.port)/")!))
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    private func buildMenu() {
        let mainMenu = NSMenu()

        // Меню приложения
        let appItem = NSMenuItem()
        mainMenu.addItem(appItem)
        let appMenu = NSMenu()
        appItem.submenu = appMenu
        appMenu.addItem(withTitle: "About AirPods Head Tracker",
                        action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        appMenu.addItem(.separator())
        appMenu.addItem(withTitle: "Hide", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
        appMenu.addItem(.separator())
        appMenu.addItem(withTitle: "Quit AirPods Head Tracker",
                        action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")

        // Edit — чтобы работали Cmd+C/V/X/A в полях интерфейса
        let editItem = NSMenuItem()
        mainMenu.addItem(editItem)
        let editMenu = NSMenu(title: "Edit")
        editItem.submenu = editMenu
        editMenu.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editMenu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")

        // Window
        let windowItem = NSMenuItem()
        mainMenu.addItem(windowItem)
        let windowMenu = NSMenu(title: "Window")
        windowItem.submenu = windowMenu
        windowMenu.addItem(withTitle: "Minimize", action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m")
        windowMenu.addItem(withTitle: "Close", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
        NSApp.windowsMenu = windowMenu

        NSApp.mainMenu = mainMenu
    }
}
