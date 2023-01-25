//
//  BiomeFinderView.swift
//  ios-archi
//
//  Created by takayuki.yokoda on 2023/01/26.
//

import SwiftUI
import WebKit

struct BiomeFinderView: UIViewRepresentable {
    private let loadUrl = "https://www.chunkbase.com/apps/biome-finder#132431431"

    var mapGotoX: Int
    var mapGotoZ: Int

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.load(URLRequest(url: URL(string: loadUrl)!))
    }

    class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate {
        var parent: BiomeFinderView

        init(_ biomeFinderView: BiomeFinderView) {
            parent = biomeFinderView
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript(
                """
                document.getElementById('map-goto-x').value = '\(parent.mapGotoX)';
                document.getElementById('map-goto-z').value = '\(parent.mapGotoZ)';
                document.getElementById("map-goto-go").click();
                """
            ) { _, error in
                if let error = error {
                    print(error)
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}

struct BiomeFinderView_Previews: PreviewProvider {
    static var previews: some View {
        BiomeFinderView(mapGotoX: 1500, mapGotoZ: -1500)
    }
}
