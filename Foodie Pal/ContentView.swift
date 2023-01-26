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
        VStack {
            Text("Hej")
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
