//
//  BottleSummaryView.swift
//  Ripple
//

import SwiftData
import SwiftUI

struct BottleSummaryView: View {
    let bottle: Bottle
    @Bindable var hydrationViewModel: HydrationViewModel
    @Bindable var scanner: NFCBottleScanner

    @Query private var entries: [DrinkEntry]

    init(
        bottle: Bottle,
        hydrationViewModel: HydrationViewModel,
        scanner: NFCBottleScanner
    ) {
        self.bottle = bottle
        self.hydrationViewModel = hydrationViewModel
        self.scanner = scanner

        let startOfToday = Calendar.current.startOfDay(for: Date())
        let bottleID = bottle.id
        _entries = Query(
            filter: #Predicate<DrinkEntry> {
                $0.timestamp >= startOfToday && $0.bottle.id == bottleID
            },
            sort: \DrinkEntry.timestamp,
            order: .reverse
        )
    }

    private var totalToday: Int {
        entries.reduce(0) { $0 + $1.amountML }
    }

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "waterbottle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.blue)

            Text(bottle.name)
                .font(.title2.bold())

            Text("\(bottle.capacityML) ml")
                .font(.headline)

            Text("Owned by \(bottle.owner.name)")
                .foregroundStyle(.secondary)

            Divider()

            Text("\(totalToday) ml today")
                .font(.title.bold())

            Text("\(entries.count) bottle\(entries.count == 1 ? "" : "s") logged")
                .foregroundStyle(.secondary)

            Button {
                scanner.beginScan { result in
                    switch result {
                    case .success(let url):
                        hydrationViewModel.logScannedTag(url: url)
                    case .failure(let error):
                        hydrationViewModel.showScanError(error)
                    }
                }
            } label: {
                Label(
                    scanner.isScanning ? "Scanning…" : "Scan Bottle Tag",
                    systemImage: "wave.3.right"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(scanner.isScanning)

            Button("Log Bottle Manually") {
                hydrationViewModel.logFullBottle(bottle)
            }
            .buttonStyle(.bordered)

            if let message = hydrationViewModel.confirmationMessage {
                Label(message, systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }

            if let error = hydrationViewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 4) {
                Text("Tag value")
                    .font(.caption.bold())
                Text(BottleTag(bottleID: bottle.id).url.absoluteString)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 8)
        }
        .padding()
    }
}
