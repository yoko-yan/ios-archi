import SwiftUI

@MainActor
struct TimeLineView: View {
    @State private var viewModel: TimeLineViewModel
    @State private var isShowEditView = false

    var body: some View {
        @Bindable var viewModel = viewModel
        ZStack(alignment: .bottomTrailing) {
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
                    .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
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
                isShowEditView = true
            }, label: {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(.white)
            })
            .padding(.trailing, 16)
            .padding(.bottom, 16)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle(Text("HomeView.Title", bundle: .module))
        .toolbarBackground(.visible, for: .navigationBar)
        .analyticsScreen(name: "TimeLineView", class: String(describing: type(of: self)))
        .sheet(isPresented: $isShowEditView) {
            ItemEditView(onChange: { _ in
                Task {
                    await viewModel.send(action: .reload)
                }
            })
        }
    }

    init() {
        self.init(viewModel: TimeLineViewModel())
    }

    private init(viewModel: TimeLineViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }
}

// MARK: - Previews

#Preview {
    TimeLineView()
}
