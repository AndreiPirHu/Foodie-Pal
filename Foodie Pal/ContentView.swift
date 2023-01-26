//
//  ContentView.swift
//  Foodie Pal
//
//  Created by Andrei Pirogov on 2023-01-25.
//

import SwiftUI
import Firebase
import MapKit

struct ContentView: View {
    let db = Firestore.firestore()
    
    @State var regionStockholm = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 59.30713183216659, longitude: 18.07499885559082), span:MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    
    var body: some View {
        Map(coordinateRegion: $regionStockholm)
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
