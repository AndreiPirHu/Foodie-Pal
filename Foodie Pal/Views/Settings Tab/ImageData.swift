//
//  ImageData.swift
//  Foodie Pal
//
//  Created by Andrei Pirogov on 2023-02-15.
//

import Foundation
import SwiftUI

struct ImageData: Hashable, Identifiable {
    var id = UUID()
    let docID: String
    let url: String
    let image: UIImage
}
