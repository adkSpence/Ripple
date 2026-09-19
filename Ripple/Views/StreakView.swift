import SwiftUI

struct StreakView: View {
    let progress: HydrationProgress

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Label("\(progress.streak)-day flow", systemImage: "drop.fill")
                    .font(.headline)
                    .foregroundStyle(.blue)
                Spacer()
                Text("Last 7 days").font(.caption).foregroundStyle(.secondary)
            }

            HStack {
                ForEach(progress.recentDays) { day in
                    VStack(spacing: 5) {
                        Image(systemName: day.isComplete ? "drop.fill" : "drop")
                            .foregroundStyle(day.isComplete ? .blue : .secondary.opacity(0.5))
                            .font(.title3)
                        Text(day.date, format: .dateTime.weekday(.narrow))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}
