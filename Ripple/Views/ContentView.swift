//
//  ContentView.swift
//  Ripple
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel: HydrationViewModel

    init(viewModel: HydrationViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Text(viewModel.title)
    }
}
