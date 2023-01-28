//
//  HomeView.swift
//  ios-archi
//
//  Created by yokoda.takayuki on 2023/01/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    @State private var seedImageData: Data = .init(capacity: 0)
    @State private var positionImageData: Data = .init(capacity: 0)
    @State private var isSeedImagePicker = false
    @State private var isPositionImagePicker = false
    @State private var isBiomeFinderView = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ZStack {
                        NavigationLink(
                            destination:
                                ImagePicker(
                                    show: $isSeedImagePicker,
                                    image: $seedImageData,
                                    sourceType: .photoLibrary
                                ),
                            isActive: $isSeedImagePicker,
                            label: { Text("") }
                        )
                        NavigationLink(
                            destination:
                                ImagePicker(
                                    show: $isPositionImagePicker,
                                    image: $positionImageData,
                                    sourceType: .photoLibrary
                                ),
                            isActive: $isPositionImagePicker,
                            label: { Text("") }
                        )
                        NavigationLink(
                            destination:
                                BiomeFinderView(
                                    seed: viewModel.state.seed.rawValue,
                                    positionX: viewModel.state.position.x,
                                    positionZ: viewModel.state.position.z
                                ),
                            isActive: $isBiomeFinderView,
                            label: { Text("") }
                        )
                        VStack {
                            if seedImageData.count != 0{
                                Image(
                                    uiImage: UIImage(data: seedImageData)!
                                )
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(.all)
                            }
                            Button {
                                self.isSeedImagePicker.toggle()
                            } label: {
                                Text("画像からSeed値を取得")
                            }
                            .padding(.all)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                            HStack {
                                Text("シード値 : ")
                                Text(viewModel.state.seedText)
                            }
                            if positionImageData.count != 0{
                                Image(
                                    uiImage: UIImage(data: positionImageData)!
                                )
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding()
                            }
                            Button {
                                self.isPositionImagePicker.toggle()
                            } label: {
                                Text("画像から座標を取得")
                            }
                            .padding(.all)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                            HStack {
                                Text("座標 : ")
                                Text(viewModel.state.positionText)
                            }
                            Button {
                                self.isBiomeFinderView.toggle()
                            } label: {
                                Text("Show Biome Finder")
                            }
                            .padding(.all)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                        }
                    }
                }
            }
            .onChange(of: seedImageData) { imageData in
                viewModel.clearSeed()
                viewModel.getSeed(imageData: imageData)
            }
            .onChange(of: positionImageData) { imageData in
                viewModel.clearPosition()
                viewModel.getPosition(imageData: imageData)
            }
//            .onChange(of: viewModel.state) { [oldState = viewModel.state] newState in
//                if oldState.recognizedText != newState.recognizedText {
//                }
//            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
