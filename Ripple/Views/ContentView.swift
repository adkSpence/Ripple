//
//  ContentView.swift
//  Ripple
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Query(sort: \Bottle.name) private var bottles: [Bottle]
    @State private var bottleSetupViewModel: BottleSetupViewModel

    init(bottleSetupViewModel: BottleSetupViewModel) {
        _bottleSetupViewModel = State(initialValue: bottleSetupViewModel)
    }

    var body: some View {
        NavigationStack {
            Group {
                if let bottle = bottles.first {
                    BottleSummaryView(bottle: bottle)
                } else {
                    FirstBottleSetupView(viewModel: bottleSetupViewModel)
                }
            }
            .navigationTitle("Ripple")
        }
    }
}
