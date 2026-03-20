import Cocoa
import WebKit

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var webView: WKWebView!

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupWindow()
        setupWebView()
        loadStream()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    // MARK: - Window Setup

    private func setupWindow() {
        let windowRect = NSRect(x: 0, y: 0, width: 480, height: 320)
        window = NSWindow(
            contentRect: windowRect,
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Lofi Streamer"
        window.minSize = NSSize(width: 360, height: 240)
        window.center()
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.backgroundColor = .black
        window.makeKeyAndOrderFront(nil)
    }

    // MARK: - WebView Setup

    private func setupWebView() {
        guard let contentView = window.contentView else { return }

        let config = WKWebViewConfiguration()
        config.preferences.setValue(true, forKey: "allowsInlineMediaPlayback")
        config.mediaTypesRequiringUserActionForPlayback = []

        webView = WKWebView(frame: contentView.bounds, configuration: config)
        webView.autoresizingMask = [.width, .height]
        webView.navigationDelegate = self
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"
        contentView.addSubview(webView)
    }

    // MARK: - Stream

    private func loadStream() {
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
        <meta charset="UTF-8">
        <meta name="referrer" content="strict-origin-when-cross-origin">
        <style>
          * { margin: 0; padding: 0; box-sizing: border-box; }
          html, body { width: 100%; height: 100%; overflow: hidden; background: #0f0f0f; }
          iframe { position: absolute; top: 0; left: 0; width: 100%; height: 100%; border: 0; }
        </style>
        </head>
        <body>
        <iframe
          src="https://www.youtube-nocookie.com/embed/jfKfPfyJRdk?autoplay=1&controls=0&modestbranding=1&rel=0"
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
          referrerpolicy="strict-origin-when-cross-origin"
          allowfullscreen>
        </iframe>
        </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: URL(string: "https://www.youtube-nocookie.com"))
    }
}

// MARK: - WKNavigationDelegate

extension AppDelegate: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Stay within the embed — block navigations away from it
        if let url = navigationAction.request.url,
           navigationAction.navigationType == .linkActivated {
            NSWorkspace.shared.open(url)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
}

// MARK: - App Entry Point

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.activate(ignoringOtherApps: true)
app.run()
