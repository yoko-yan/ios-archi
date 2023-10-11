//
//  Created by takayuki.yokoda on 2023/10/07
//

import SwiftUI

struct TimeLineView: View {
    @StateObject private var viewModel: TimeLineViewModel
    @State private var isShowDetailView = false

    var body: some View {
        ZStack {
            List {
                ForEach(viewModel.uiState.items, id: \.self) { item in
                    NavigationLink(value: item) {
                        let image = viewModel.loadImage(fileName: item.spotImageName)
                        TimeLineCell(item: item, image: image)
                            .padding(.top)
                    }
                }
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .task {
                viewModel.send(.load)
            }
            .refreshable {
                viewModel.send(.load)
            }
            .navigationDestination(for: Item.self) { item in
                DetailView(item: item)
            }

            FloatingButton(action: {
                isShowDetailView.toggle()
            }, label: {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .font(.system(size: 24))
            })
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle(Text("ホーム"))
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $isShowDetailView) {
            EditItemView(
                onTapDismiss: { _ in
                    viewModel.send(.reload)
                }
            )
        }
    }

    init() {
        self.init(viewModel: TimeLineViewModel())
    }

    private init(viewModel: TimeLineViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
}

#Preview {
    TimeLineView()
}
