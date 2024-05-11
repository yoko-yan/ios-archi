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
    var coordinates: Coordinates

    func makeUIView(context: Context) -> WKWebView {
        _ = analyticsScreen(name: "BiomeFinderView", class: String(describing: type(of: self)))

        let userScript1 = WKUserScript(
            source:
            """
            document.getElementById('map-goto-x').value = '\(coordinates.x)';
            document.getElementById('map-goto-z').value = '\(coordinates.z)';
            document.getElementById("map-goto-go").click();
            """,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )

        let controller = WKUserContentController()
        controller.addUserScript(userScript1)

        let configuration = WKWebViewConfiguration()
        configuration.userContentController = controller

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ webView: WKWebView, context _: Context) {
        webView.load(
            // swiftlint:disable:next force_unwrapping
            URLRequest(url: URL(string: "https://www.chunkbase.com/apps/biome-finder#\(seed)")!)
        )
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

#Preview {
    BiomeFinderView(
        seed: 132431431,
        coordinates: Coordinates(x: 1500, y: 500, z: -1500)! // swiftlint:disable:this force_unwrapping
    )
}
