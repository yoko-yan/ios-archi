//
//  AddItemView.swift
//
//
//  Created by takayuki.yokoda on 2023/07/03.
//

import SwiftUI

struct AddItemView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var path: [Item] = []

    var body: some View {
        NavigationStack(path: $path) {
            DetailView(item: Item(seed: .zero, coordinates: .zero))
                .navigationBarTitle("新規追加", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            print("右のボタンが押されたよ")
                        }) {
                            HStack {
                                Text("追加")
                            }
                        }
                    }
                }
        }
    }
}

struct AddItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddItemView()
    }
}
