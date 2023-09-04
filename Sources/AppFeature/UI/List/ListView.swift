//
//  Created by takayuki.yokoda on 2023/07/01.
//

import SwiftUI

struct ListView: View {
    @StateObject private var viewModel: ListViewModel
    @State private var isShowDetailView = false

    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    ForEach(viewModel.uiState.items, id: \.self) { item in
                        NavigationLink(value: item) {
                            let image = viewModel.loadImage(fileName: item.coordinatesImageName)
                            ListCell(item: item, image: image)
                                .padding(.top)
                        }
                    }
                    .onDelete(perform: delete)
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .task {
                    viewModel.loadItems()
                }
                .refreshable {
                    viewModel.loadItems()
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
            .navigationBarTitle(Text("スポット一覧"))
//            .navigationBarItems(trailing: EditButton())
            .toolbarBackground(.visible, for: .navigationBar)
            .fullScreenCover(isPresented: $isShowDetailView) {
                EditItemView(
                    onTapDismiss: { _ in
                        viewModel.reload()
                    }
                )
            }
        }
    }

    func delete(offsets: IndexSet) {
        viewModel.delete(offsets: offsets)
    }

    init() {
        self.init(viewModel: ListViewModel())
    }

    private init(viewModel: ListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
}

#Preview {
    ListView()
}
