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
    }

    var seed: Int
    var positionX: Int
    var positionZ: Int

    func makeUIView(context: Context) -> WKWebView {
        let webView: WKWebView
        let userScript1 = WKUserScript(
            source:
            """
            document.getElementById('map-goto-x').value = '\(positionX)';
            document.getElementById('map-goto-z').value = '\(positionZ)';
            document.getElementById("map-goto-go").click();
            """,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )

        let controller = WKUserContentController()
        controller.addUserScript(userScript1)

        let configuration = WKWebViewConfiguration()
        configuration.userContentController = controller

        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ webView: WKWebView, context _: Context) {
        webView.load(
            // swiftlint:disable:next force_unwrapping
            URLRequest(url: URL(string: String(format: "https://www.chunkbase.com/apps/biome-finder#%d", seed))!)
        )
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
