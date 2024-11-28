//
//  ContentView.swift
//  kitchen_script
//
//  Created by Theron Boerner on 11/23/24.
//

import SwiftUI
import SwiftData

@available(macOS 10.15, *)
struct ContentView: View {
    @State var placeholderData = PlaceholderData(data: [
        PlaceholderEntry(type: .plain("foo")),
        PlaceholderEntry(type: .token("bar")),
    ])
    
    var body: some View {
        MyTokenFieldPreview(placeholderData: $placeholderData)
    }
}

#Preview {
    ContentView()
}
