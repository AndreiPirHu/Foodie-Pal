//
//  UserSettingsView.swift
//  Foodie Pal
//
//  Created by Andrei Pirogov on 2023-01-28.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct UserSettingsView: View {
    let db = Firestore.firestore()
    
    var body: some View {
        
        
        if let userUid = Auth.auth().currentUser?.uid {
            Text("Hello user \(userUid)")
        }
            

        //Text("Signed in \(Auth.auth().currentUser?.uid)")
        //Text("Hello user \(userUid)")
    
        
    }
}

struct UserSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        UserSettingsView()
    }
}
