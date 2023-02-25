//
//  UserMessages.swift
//  Foodie Pal
//
//  Created by Andrei Pirogov on 2023-02-19.
//

import Foundation
import FirebaseFirestoreSwift


struct UserMessages: Codable, Hashable {
    @DocumentID var id : String?
    
    var message: String?
    var date: String?
    var messagePosition: Int?
    
}
