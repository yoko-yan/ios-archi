import Dependencies
import SwiftUI

@MainActor
struct SpotListView: View {
    @State private var viewModel: SpotListViewModel
    @State private var isShowEditView = false

    private let columns = [
        GridItem(.adaptive(minimum: 80))
    ]

    var body: some View {
        @Bindable var viewModel = viewModel
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                FilterConditionCell(
                    label: "Display only items with images",
                    isChecked: $viewModel.isChecked
                ) { isChecked in
                    Task {
                        await viewModel.send(action: .isChecked(isChecked))
                    }
                }
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(viewModel.uiState.items, id: \.self) { item in
                        NavigationLink(value: item) {
                            SpotListCell(
                                item: item,
                                spotImage: viewModel.uiState.spotImages[item.id] as? SpotImage
                            ) { item in
                                viewModel.loadImage(item: item)
                            }
                        }
                    }
                }
                .padding(8)
                .navigationDestination(for: Item.self) { item in
                    ItemDetailView(item: item)
                }
            }
            .task {
                await viewModel.send(action: .load)
            }
            .refreshable {
                await viewModel.send(action: .load)
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
        .navigationBarTitle(Text("SpotListView.Title", bundle: .module))
        .toolbarBackground(.visible, for: .navigationBar)
        .analyticsScreen(name: "SpotListView", class: String(describing: type(of: self)))
        .sheet(isPresented: $isShowEditView) {
            ItemEditView(onChange: { _ in
                Task {
                    await viewModel.send(action: .reload)
                }
            })
        }
    }

    init() {
        self.init(viewModel: SpotListViewModel())
    }

    init(viewModel: SpotListViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }
}

// MARK: - Previews

#if DEBUG
@available(iOS 17.0, *)
#Preview(traits: .sizeThatFitsLayout) {
    withDependencies {
        $0.itemsRepository = ItemsRepositoryImpl.preview
        $0.loadSpotImageUseCase = LoadSpotImageUseCaseImpl.preview
    } operation: {
        SpotListView()
    }
}
#endif
