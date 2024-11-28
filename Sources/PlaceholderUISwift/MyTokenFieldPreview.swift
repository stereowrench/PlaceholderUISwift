//
//  MyTokenFieldPreview.swift
//  kitchen_script
//
//  Created by Theron Boerner on 11/23/24.
//

import Foundation
import SwiftUI

struct MyTokenFieldPreview: View {
    @Binding var placeholderData: PlaceholderData;
    var body: some View {
        VStack {
            ForEach(placeholderData.data) { placeholder in
                switch placeholder.type {
                case .plain(let str):
                    Text("Plain \(str)")
                case .token(let str):
                    Text("Token \(str)")
                }
            }
            MyTokenField(placeholderData: $placeholderData)
        }
        .padding()
    }
}

#Preview {
    @State var placeholderField: PlaceholderData = PlaceholderData(data: [
        PlaceholderEntry(type: .plain("foo")),
        PlaceholderEntry(type: .token("bar")),
    ])
    return MyTokenFieldPreview(placeholderData: $placeholderField)
}
