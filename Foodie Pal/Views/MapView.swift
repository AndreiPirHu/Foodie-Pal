//
//  MapView.swift
//  Foodie Pal
//
//  Created by Andrei Pirogov on 2023-01-27.
//

import SwiftUI
import MapKit

struct MapView: View {
    
    @State var regionStockholm = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 59.30713183216659, longitude: 18.07499885559082), span:MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    
    
    var body: some View {
        Map(coordinateRegion: $regionStockholm)
        
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
