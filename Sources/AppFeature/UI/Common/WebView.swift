//
//  Created by takayuki.yokoda on 2023/01/26.
//

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

#Preview {
    WebView(loadUrl: "https://www.chunkbase.com")
}
