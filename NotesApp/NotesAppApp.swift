//
//  NotesAppApp.swift
//  NotesApp
//
//  Created by Dominik Butz on 5/12/2023.
//

import SwiftUI

@main
struct NotesAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
