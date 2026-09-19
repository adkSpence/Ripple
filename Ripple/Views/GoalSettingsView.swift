import SwiftUI

struct GoalSettingsView: View {
    let user: User
    @Bindable var viewModel: HydrationGoalViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Daily hydration goal") {
                    TextField("Goal in millilitres", text: $viewModel.goalText)
                        .keyboardType(.numberPad)
                }
                if let error = viewModel.errorMessage {
                    Section { Text(error).foregroundStyle(.red) }
                }
            }
            .navigationTitle("Daily Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if viewModel.save(for: user) { dismiss() }
                    }
                }
            }
        }
    }
}
