//
//  projectApp.swift
//  project
//
//  Created by vm on 4/3/21.
//

import SwiftUI

@main
struct projectApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
