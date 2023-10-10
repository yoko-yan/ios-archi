//
//  Created by apla on 2023/10/08
//

import SwiftUI

struct SpotView: View {
    @StateObject private var viewModel = SpotViewModel()

    private let columns = [
        GridItem(.adaptive(minimum: 80))
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(viewModel.uiState.items, id: \.self) { item in
                    let image = viewModel.loadImage(fileName: item.coordinatesImageName)
                    SpotCell(item: item, image: image)
                        .padding(.bottom, 4)
                }
            }
            .padding(.horizontal)
            .padding(.top)
        }
//        .frame(maxHeight: 300)
        .task {
            viewModel.send(.load)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle(Text("スポット一覧"))
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    SpotView()
}
