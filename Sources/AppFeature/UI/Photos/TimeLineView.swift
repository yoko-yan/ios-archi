//
//  Created by takayuki.yokoda on 2023/10/07
//

import PhotosUI
import SwiftUI

struct TimeLineView: View {
    @StateObject private var viewModel: TimeLineViewModel
    @State private var isShowDetailView = false
    @State var selectedItems: [PhotosPickerItem] = []

    var body: some View {
        NavigationStack {
            PhotosPicker(
                selection: $selectedItems,
                matching: .images
            ) {
                Text("Select Multiple Photos")
            }
            ZStack {
                List {
                    ForEach(viewModel.uiState.items, id: \.self) { item in
                        NavigationLink(value: item) {
                            let image = viewModel.loadImage(fileName: item.coordinatesImageName)
                            PhotoCell(item: item, image: image)
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
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle(Text("スポット一覧"))
            .navigationBarItems(trailing: EditButton())
            .toolbarBackground(.visible, for: .navigationBar)
            .fullScreenCover(isPresented: $isShowDetailView) {
                EditItemView(
                    onTapDismiss: { _ in
                        viewModel.send(.reload)
                    }
                )
            }
            .deleteAlert(
                message: viewModel.uiState.deleteAlertMessage,
                onDelete: { viewModel.send(.onDelete) },
                onDismiss: { viewModel.send(.onDeleteAlertDismiss) }
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

// MARK: - Privates

extension View {
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
    TimeLineView()
}
