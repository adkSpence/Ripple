import SwiftData
import SwiftUI

struct BottleSummaryView: View {
    let bottle: Bottle
    @Bindable var hydrationViewModel: HydrationViewModel
    @Bindable var bottleTagViewModel: BottleTagViewModel
    @Bindable var hydrationGoalViewModel: HydrationGoalViewModel
    @Bindable var scanner: NFCBottleScanner

    @Query(sort: \DrinkEntry.timestamp, order: .reverse) private var allEntries: [DrinkEntry]
    @State private var isShowingGoal = false

    private var entries: [DrinkEntry] {
        allEntries.filter { $0.bottle.owner.id == bottle.owner.id }
    }

    private var progress: HydrationProgress {
        HydrationProgress.calculate(entries: entries, goalML: bottle.owner.dailyGoalML)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                header

                WaterProgressView(
                    progress: progress.fractionComplete,
                    amountML: progress.amountTodayML,
                    goalML: progress.goalML,
                    animationTrigger: hydrationViewModel.lastLoggedEntry?.id
                )

                Text(progress.isComplete
                     ? "Daily goal complete"
                     : "\(progress.remainingML.formatted()) ml remaining")
                    .font(.headline)
                    .foregroundStyle(progress.isComplete ? .green : .secondary)

                StreakView(progress: progress)
                actionButtons
                feedback
            }
            .padding()
        }
        .background(LinearGradient(
            colors: [.cyan.opacity(0.08), .blue.opacity(0.03), .clear],
            startPoint: .top,
            endPoint: .bottom
        ))
        .sheet(isPresented: $isShowingGoal) {
            GoalSettingsView(user: bottle.owner, viewModel: hydrationGoalViewModel)
        }
        .sensoryFeedback(.success, trigger: progress.isComplete)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("Hello, \(bottle.owner.name)").font(.title2.bold())
                Text("\(bottle.name) · \(bottle.capacityML) ml")
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                hydrationGoalViewModel.prepare(currentGoalML: bottle.owner.dailyGoalML)
                isShowingGoal = true
            } label: {
                Image(systemName: "target").font(.title2)
            }
            .accessibilityLabel("Set daily goal")
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                scanner.beginScan { result in
                    switch result {
                    case .success(let url): hydrationViewModel.logScannedTag(url: url)
                    case .failure(let error): hydrationViewModel.showScanError(error)
                    }
                }
            } label: {
                Label(scanner.isScanning ? "Scanning…" : "Scan Bottle Tag", systemImage: "wave.3.right")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(scanner.isScanning || bottleTagViewModel.isWriting)

            HStack {
                Button("Log Manually") { hydrationViewModel.logFullBottle(bottle) }
                    .buttonStyle(.bordered)

                Button {
                    bottleTagViewModel.connectTag(to: bottle)
                } label: {
                    Text(bottleTagViewModel.isWriting
                         ? "Connecting…"
                         : bottle.isTagConnected ? "Replace Tag" : "Connect Tag")
                }
                .buttonStyle(.bordered)
                .disabled(bottleTagViewModel.isWriting || scanner.isScanning)
            }
        }
    }

    @ViewBuilder
    private var feedback: some View {
        if let message = hydrationViewModel.confirmationMessage {
            Label(message, systemImage: "checkmark.circle.fill").foregroundStyle(.green)
        }
        if let message = bottleTagViewModel.confirmationMessage {
            Label(message, systemImage: "checkmark.circle.fill").foregroundStyle(.green)
        }
        if let error = hydrationViewModel.errorMessage ?? bottleTagViewModel.errorMessage {
            Text(error).foregroundStyle(.red).multilineTextAlignment(.center)
        }
    }
}
