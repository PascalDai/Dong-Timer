//
//  Dong_TimerApp.swift
//  Dong Timer
//
//  Created by Pascal on 2024/10/6.
//

import SwiftUI

@main
struct Dong_TimerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
