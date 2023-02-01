//
//  UserSettings.swift
//  Foodie Pal
//
//  Created by Andrei Pirogov on 2023-01-30.
//

import Foundation
import FirebaseFirestoreSwift

struct UserSettings: Identifiable {
    let id = UUID()
    var description : String
    var email : String
    var name : String
    var address : String
    
    
}
