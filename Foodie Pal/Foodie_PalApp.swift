//
//  Foodie_PalApp.swift
//  Foodie Pal
//
//  Created by Andrei Pirogov on 2023-01-25.
//

import SwiftUI
import Firebase

@main
struct Foodie_PalApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
