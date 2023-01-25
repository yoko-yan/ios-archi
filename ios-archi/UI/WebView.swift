//
//  WebView.swift
//  ios-archi
//
//  Created by takayuki.yokoda on 2023/01/26.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    var loadUrl: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.load(URLRequest(url: URL(string: loadUrl)!))
    }
}

struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        WebView(loadUrl: "https://www.chunkbase.com")
    }
}
