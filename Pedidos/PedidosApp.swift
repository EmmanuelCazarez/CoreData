//
//  PedidosApp.swift
//  Pedidos
//
//  Created by Emmanuel on 23/11/22.
//

import SwiftUI

@main
struct PedidosApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
