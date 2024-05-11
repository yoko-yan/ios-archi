import SwiftUI

@MainActor
struct TimeLineView: View {
    @State private var viewModel: TimeLineViewModel
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
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle(Text("HomeView.Title", bundle: .module))
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
        .analyticsScreen(name: "TimeLineView", class: String(describing: type(of: self)))
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
