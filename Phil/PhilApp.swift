//
//  PhilApp.swift
//  Phil
//
//  Created by Rene  on 03/10/23.
//

import SwiftUI

@main
struct Phil: App {
    @StateObject private var dataController = DataController()
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}

