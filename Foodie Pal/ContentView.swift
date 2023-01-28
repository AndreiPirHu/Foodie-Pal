//
//  ContentView.swift
//  Foodie Pal
//
//  Created by Andrei Pirogov on 2023-01-25.
//

import SwiftUI
import Firebase

struct ContentView: View {
    let db = Firestore.firestore()
    
   
    var body: some View {
        TabView {
            MapView()
                .tabItem() {
                    Image(systemName: "map.fill")
                        Text("Karta")
                }
            ListView()
                .tabItem() {
                    Image(systemName: "list.bullet")
                    Text("Lista")
                }
            SettingsView()
                .tabItem() {
                    Image(systemName: "slider.horizontal.3")
                        Text("Inställningar")
                }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
