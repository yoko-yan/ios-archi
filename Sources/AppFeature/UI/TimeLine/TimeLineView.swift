//
//  Created by yoko-yan on 2023/10/07
//

import Core
import SwiftUI

struct TimeLineView: View {
    @StateObject private var viewModel: TimeLineViewModel
    @State private var isShowEditView = false

    var body: some View {
        ZStack {
            List {
                ForEach(viewModel.uiState.items, id: \.self) { item in
                    HStack {
                        TimeLineCell(
                            item: item,
                            spotImage: viewModel.uiState.spotImages[item.id] as? SpotImage
                        ) { item in
                            viewModel.loadImage(item: item)
                        }
                        NavigationLink(value: item) {
                            EmptyView()
                        }
                        .frame(width: 0)
                        .opacity(0)
                    }
                }
                .listRowSeparator(.hidden)
            }
            .padding(.top, 8)
            .listStyle(.plain)
            .task {
                await viewModel.send(action: .load)
            }
            .refreshable {
                await viewModel.send(action: .load)
            }
            .navigationDestination(for: Item.self) { item in
                ItemDetailView(item: item)
            }

            FloatingButton(action: {
                isShowEditView.toggle()
            }, label: {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .font(.system(size: 24))
            })
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle(Text("home"))
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $isShowEditView) {
            ItemEditView(
                onChange: { _ in
                    Task {
                        await viewModel.send(action: .reload)
                    }
                }
            )
        }
        .analyticsScreen(name: "TimeLineView", class: String(describing: type(of: self)))
    }

    init() {
        self.init(viewModel: TimeLineViewModel())
    }

    private init(viewModel: TimeLineViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
}

// MARK: - Previews

#Preview {
    TimeLineView()
}
