//
//  ContentView.swift
//  Ripple
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Query(sort: \Bottle.name) private var bottles: [Bottle]
    @State private var bottleSetupViewModel: BottleSetupViewModel
    @State private var hydrationViewModel: HydrationViewModel
    @State private var bottleTagViewModel: BottleTagViewModel
    @State private var scanner = NFCBottleScanner()

    init(
        bottleSetupViewModel: BottleSetupViewModel,
        hydrationViewModel: HydrationViewModel,
        bottleTagViewModel: BottleTagViewModel
    ) {
        _bottleSetupViewModel = State(initialValue: bottleSetupViewModel)
        _hydrationViewModel = State(initialValue: hydrationViewModel)
        _bottleTagViewModel = State(initialValue: bottleTagViewModel)
    }

    var body: some View {
        NavigationStack {
            Group {
                if let bottle = bottles.first {
                    BottleSummaryView(
                        bottle: bottle,
                        hydrationViewModel: hydrationViewModel,
                        bottleTagViewModel: bottleTagViewModel,
                        scanner: scanner
                    )
                } else {
                    FirstBottleSetupView(viewModel: bottleSetupViewModel)
                }
            }
            .navigationTitle("Ripple")
        }
    }
}
