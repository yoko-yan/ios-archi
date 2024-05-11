import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    var loadUrl: String

    func makeUIView(context _: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context _: Context) {
        // swiftlint:disable:next force_unwrapping
        webView.load(URLRequest(url: URL(string: loadUrl)!))
    }
}

// MARK: - Previews

#Preview {
    WebView(loadUrl: "https://www.chunkbase.com")
}
