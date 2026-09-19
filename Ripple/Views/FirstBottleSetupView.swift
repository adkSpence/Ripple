//
//  FirstBottleSetupView.swift
//  Ripple
//

import SwiftUI

struct FirstBottleSetupView: View {
    @Bindable var viewModel: BottleSetupViewModel

    var body: some View {
        Form {
            Section("Profile") {
                TextField("Your name", text: $viewModel.userName)
                    .textContentType(.name)
            }

            Section("First bottle") {
                TextField("Bottle name", text: $viewModel.bottleName)
                TextField("Capacity (ml)", text: $viewModel.capacityText)
                    .keyboardType(.numberPad)
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .accessibilityLabel("Error: \(errorMessage)")
                }
            }

            Section {
                Button("Save Bottle") {
                    viewModel.save()
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}
