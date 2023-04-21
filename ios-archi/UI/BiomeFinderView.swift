//
//  BiomeFinderView.swift
//  ios-archi
//
//  Created by takayuki.yokoda on 2023/01/26.
//

import SwiftUI
import WebKit

struct BiomeFinderView: UIViewRepresentable {
    class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate {
        var parent: BiomeFinderView

        init(_ biomeFinderView: BiomeFinderView) {
            parent = biomeFinderView
        }

        func webView(_ webView: WKWebView, didFinish _: WKNavigation?) {
            webView.evaluateJavaScript(
                """
                document.getElementById('map-goto-x').value = '\(parent.positionX)';
                document.getElementById('map-goto-z').value = '\(parent.positionZ)';
                document.getElementById("map-goto-go").click();
                """
            ) { _, error in
                if let error {
                    print(error)
                }
            }
        }
    }

    private let loadUrl = "https://www.chunkbase.com/apps/biome-finder#%d"

    var seed: Int
    var positionX: Int
    var positionZ: Int

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ webView: WKWebView, context _: Context) {
        webView.load(URLRequest(url: URL(string: String(format: loadUrl, seed))!))
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

struct BiomeFinderView_Previews: PreviewProvider {
    static var previews: some View {
        BiomeFinderView(
            seed: 132431431,
            positionX: 1500,
            positionZ: -1500
        )
    }
}
