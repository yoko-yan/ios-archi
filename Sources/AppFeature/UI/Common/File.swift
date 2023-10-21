//
//  Created by apla on 2023/10/22
//

import SwiftUI

struct SyncImage: View {
    let fileName: String
    @ObservedObject private var imageDownloader = ImageDownloader()

    init(fileName: String) {
        self.fileName = fileName
        imageDownloader.cloudSync(fileName: self.fileName)
    }

    var body: some View {
        if let image = imageDownloader.image {
            return VStack {
                Image(uiImage: image).resizable()
            }
        } else {
            return VStack {
                Image(uiImage: UIImage(systemName: "icloud.and.arrow.down")!).resizable()
            }
        }
    }
}

private class ImageDownloader: ObservableObject {
    @Published var image: UIImage?

    @Sendable
    func cloudSync(fileName: String) {
        Task {
            let image = try await RemoteImageRepository().load(fileName: fileName)
            Task { @MainActor in
                self.image = image
            }
        }
    }
}
