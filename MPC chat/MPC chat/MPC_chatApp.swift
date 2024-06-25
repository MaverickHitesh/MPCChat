//
//  MPC_chatApp.swift
//  MPC chat
//
//  Created by Hitesh Singh on 24/06/24.
//

import SwiftUI

@main
struct MPC_chatApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
