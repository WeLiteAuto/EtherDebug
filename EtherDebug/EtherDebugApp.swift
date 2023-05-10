//
//  TRIALApp.swift
//  TRIAL
//
//  Created by Aaron Ge on 2023/4/28.
//

import SwiftUI

@main
struct EtherDebugApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environment(\.locale, .init(identifier: "zh"))
        }
    }
}
