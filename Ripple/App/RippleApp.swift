//
//  RippleApp.swift
//  Ripple
//

import SwiftData
import SwiftUI

@main
struct RippleApp: App {
    private let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            Bottle.self,
            DrinkEntry.self,
        ])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView(
                bottleSetupViewModel: BottleSetupViewModel(
                    bottleSetupController: BottleSetupController(
                        modelContext: sharedModelContainer.mainContext
                    )
                )
            )
        }
        .modelContainer(sharedModelContainer)
    }
}
