//
//  SeedView.swift
//  ios-archi
//
//  Created by yokoda.takayuki on 2023/01/29.
//

import Combine
import SwiftUI

struct SeedView: View {
    let seed: Seed?
    let image: UIImage?

    var body: some View {
        VStack {
            HStack {
                Label("seed", systemImage: "globe")
                Spacer()
                Text(seed?.text ?? "未登録")
                    .bold()
            }
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
            }
        }
        .padding()
    }
}

struct SeedView_Previews: PreviewProvider {
    // swiftlint:disable force_unwrapping
    static var previews: some View {
        SeedView(
            seed: Seed(rawValue: 1234567890),
            image: UIImage(named: "sample-seed", in: Bundle.module, with: nil)!
        )
        SeedView(
            seed: nil,
            image: nil
        )
    }
    // swiftlint:enable force_unwrapping
}
