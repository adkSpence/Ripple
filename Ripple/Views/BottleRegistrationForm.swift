import SwiftUI

struct BottleRegistrationForm: View {
    @Bindable var viewModel: BottleRegistrationViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Bottle name", text: $viewModel.bottleName)
                    TextField("Capacity in ml", text: $viewModel.capacityText)
                        .keyboardType(.numberPad)
                } header: {
                    Text("Bottle details")
                } footer: {
                    if viewModel.mode == .nfc {
                        Text("After saving, hold the tag near your iPhone once more to connect it.")
                    }
                }
                if let error = viewModel.errorMessage {
                    Section { Text(error).foregroundStyle(.red) }
                }
            }
            .navigationTitle(viewModel.mode == .nfc ? "Connect Bottle" : "Add Bottle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.dismissForm()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(viewModel.isSaving ? "Connecting…" : "Save") { viewModel.save() }
                        .disabled(viewModel.isSaving)
                }
            }
        }
    }
}
