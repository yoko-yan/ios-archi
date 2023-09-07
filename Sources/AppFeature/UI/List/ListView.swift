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
                    .onDelete { viewModel.send(.onDeleteButtonClick(offsets: $0)) }
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
                .deleteAlert(
                    message: viewModel.uiState.deleteAlertMessage,
                    onDelete: { viewModel.send(.onDelete) },
                    onDismiss: { viewModel.send(.onDeleteAlertDismiss) }
                )
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle(Text("スポット一覧"))
//            .navigationBarItems(trailing: EditButton())
            .toolbarBackground(.visible, for: .navigationBar)
            .fullScreenCover(isPresented: $isShowDetailView) {
                EditItemView(
                    onTapDismiss: { _ in
                        viewModel.send(.reload)
                    }
                )
            }
        }
    }

    init() {
        self.init(viewModel: ListViewModel())
    }

    private init(viewModel: ListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
}

// MARK: - Privates

private extension View {
    func deleteAlert(
        message: String?,
        onDelete: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) -> some View {
        alert(
            "確認",
            isPresented: .init(get: {
                message != nil
            }, set: { _ in
                onDismiss()
            }),
            presenting: message
        ) { _ in
            Button("削除する", role: .destructive, action: {
                onDelete()
            })
        } message: { message in
            Text(message)
        }
    }
}

#Preview {
    ListView()
}
