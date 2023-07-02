//
//  UpdateItemView.swift
//
//
//  Created by takayuki.yokoda on 2023/07/03.
//

import SwiftUI

struct UpdateItemView: View {
    @Environment(\.presentationMode) var presentationMode

    @State var item: Item

    var body: some View {
        DetailView(item: item)
            .navigationBarTitle("", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        print("右のボタンが押されたよ")
                    }) {
                        HStack {
                            Text("更新")
                        }
                    }
                }
            }
    }
}

struct UpdateItemView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateItemView(item: Item(seed: .zero, coordinates: .zero))
    }
}
