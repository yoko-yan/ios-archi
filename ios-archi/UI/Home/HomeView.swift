//
//  HomeView.swift
//  ios-archi
//
//  Created by yokoda.takayuki on 2023/01/25.
//

import SwiftUI

struct HomeView: View {
    @State private var imageData: Data = .init(capacity: 0)
    @State private var source: UIImagePickerController.SourceType = .photoLibrary

    @State private var isImagePicker = false
    @State private var isBiomeFinderView = false

    private var viewModel = HomeViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ZStack {
                    NavigationLink(
                        destination:
                            ImagePicker(
                                show: $isImagePicker,
                                image: $imageData,
                                sourceType: source
                            ),
                        isActive: $isImagePicker,
                        label: { Text("") }
                    )
                    NavigationLink(
                        destination:
                            BiomeFinderView(mapGotoX: 100, mapGotoZ: 200),
                        isActive: $isBiomeFinderView,
                        label: { Text("") }
                    )
                    VStack(spacing: 0) {
                        if imageData.count != 0{
                            Image(
                                uiImage: UIImage(data: imageData)!
                            )
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 250)
                            .cornerRadius(15)
                            .padding()
                        }
                        Button {
                            self.isImagePicker.toggle()
                        } label: {
                            Text("Take Photo")
                        }
                        Button {
                            viewModel.getCoordinate(imageData: imageData)

                            self.isBiomeFinderView.toggle()
                        } label: {
                            Text("Show Biome Finder")
                        }
                    }
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
