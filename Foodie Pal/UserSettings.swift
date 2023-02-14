//
//  UserSettings.swift
//  Foodie Pal
//
//  Created by Andrei Pirogov on 2023-01-30.
//

import Foundation
import FirebaseFirestoreSwift

//används för UserSettingsView och UserSettingsEditView
struct UserSettings: Identifiable {
    let id = UUID()
    var description : String 
    var email : String
    var name : String
    var address : String
    
    var schedMonOpen : String = ""
    var schedMonClose : String = ""
    
    var schedTueOpen : String = ""
    var schedTueClose : String = ""
    
    var schedWedOpen : String = ""
    var schedWedClose : String = ""
    
    var schedThuOpen : String = ""
    var schedThuClose : String = ""
    
    var schedFriOpen : String = ""
    var schedFriClose : String = ""
    
    var schedSatOpen : String = ""
    var schedSatClose : String = ""
    
    var schedSunOpen : String = ""
    var schedSunClose : String = ""
    
    
}
