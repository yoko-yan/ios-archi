//
//  Created by takayuki.yokoda on 2023/10/07
//

import SwiftUI

struct TimeLineView: View {
    @StateObject private var viewModel: TimeLineViewModel
    @State private var isShowEditView = false

    var body: some View {
        ZStack {
            List {
                ForEach(viewModel.uiState.items, id: \.self) { item in
                    HStack {
                        TimeLineCell(item: item)
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
                viewModel.send(.load)
            }
            .refreshable {
                viewModel.send(.load)
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
        .navigationBarTitle(Text("ホーム"))
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $isShowEditView) {
            ItemEditView(
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

// MARK: - Previews

#Preview {
    TimeLineView()
}
