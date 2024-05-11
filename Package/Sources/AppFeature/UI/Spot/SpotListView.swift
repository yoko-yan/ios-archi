import Core
import SwiftUI

@MainActor
struct SpotListView: View {
    @State private var viewModel: SpotListViewModel
    @State private var isShowEditView = false

    private let columns = [
        GridItem(.adaptive(minimum: 80))
    ]

    var body: some View {
        ZStack {
            ScrollView {
                conditionCell
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

            FloatingButton(action: {
                isShowEditView.toggle()
            }, label: {
                ZStack {
                    ZStack {
                        Image(systemName: "photo")
                            .foregroundColor(.white)
                            .font(.system(size: 24))
                            .padding(.trailing, 10)
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 15))
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: .infinity,
                                alignment: .trailing
                            )
                            .padding(2)
                    }
                }
            })
        }
        .task {
            await viewModel.send(action: .load)
        }
        .refreshable {
            await viewModel.send(action: .load)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle(Text("SpotListView.Title", bundle: .module))
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $isShowEditView, content: {
            ItemEditView(
                onChange: { _ in
                    Task {
                        await viewModel.send(action: .reload)
                    }
                }
            )
        })
        .analyticsScreen(name: "SpotListView", class: String(describing: type(of: self)))
    }

    init() {
        self.init(viewModel: SpotListViewModel())
    }

    init(viewModel: SpotListViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }
}

// MARK: - Privates

private extension SpotListView {
    var conditionCell: some View {
        HStack {
            Checkbox(label: "Display only items with images") { isChecked in
                Task {
                    await viewModel.send(action: .isChecked(isChecked))
                }
            }
            Spacer()
        }
        .padding(.horizontal)
    }
}

// MARK: - Previews

#if DEBUG
@available(iOS 17.0, *)
#Preview(traits: .sizeThatFitsLayout) {
    InjectedValues[\.itemsRepository] = ItemsRepositoryImpl.preview
    InjectedValues[\.loadSpotImageUseCase] = LoadSpotImageUseCaseImpl.preview
    return SpotListView()
}
#endif
