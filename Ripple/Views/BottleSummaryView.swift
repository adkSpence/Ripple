//
//  BottleSummaryView.swift
//  Ripple
//

import SwiftUI

struct BottleSummaryView: View {
    let bottle: Bottle

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
        }
        .padding()
    }
}
