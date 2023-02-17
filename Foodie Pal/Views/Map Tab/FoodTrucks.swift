//
//  FoodTrucks.swift
//  Foodie Pal
//
//  Created by Andrei Pirogov on 2023-02-05.
//

import Foundation
import SwiftUI


struct FoodTrucks: Codable, Hashable{
    var name: String = ""
    var email: String = ""
    var description: String = ""
    var category: String = ""
    var address: String = ""
    
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
    
    var uid = ""
}
