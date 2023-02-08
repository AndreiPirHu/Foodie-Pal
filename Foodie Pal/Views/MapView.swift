//
//  MapView.swift
//  Foodie Pal
//
//  Created by Andrei Pirogov on 2023-01-27.
//

import SwiftUI
import MapKit
import Firebase

struct MapView: View {
    @StateObject private var mapAPI = MapAPI()
    @State private var text = ""
    @State var setMarkers = [SetMarker]()
    let db = Firestore.firestore()
    
    
    var body: some View {
        VStack {
            TextField("Enter an address", text: $text)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            
            Button(action: {
                mapAPI.getLocation(address: text, delta: 0.1)
                
            }){
                Text("Find address")
            }
            
            Map(coordinateRegion: $mapAPI.region, annotationItems: mapAPI.locations) { location in
                
                MapAnnotation(coordinate: location.coordinate, anchorPoint: CGPoint(x: 0.5, y: 1)){
                    Image("Map Marker")
                        .onTapGesture {
                            print(location.)
                        }
                        
                    
                }
                
            
                
               
                    
                
            }
    
            
            
        }
        .onAppear() {
            updateMarkersFirestore()
            //selectMarker()
            
        }
    }
    
    func updateMarkersFirestore() {
        
        db.collection("users").addSnapshotListener { snapshot, err in
            guard let snapshot = snapshot else {return}
            
            if let err = err {
                print("Error getting document \(err)")
            }else {
                setMarkers.removeAll()
                for document in snapshot.documents {
                
                    let result = Result {
                        try document.data(as: SetMarker.self)
                    }
                    switch result {
                    case .success(let setMarker) :
                        setMarkers.append(setMarker)
                        
                        for setMarker in setMarkers {
                            
                            mapAPI.getLocation(address: setMarker.address, delta: 0.1)
                            
                            
                            
                        }
                    case .failure(let error) :
                        print("Error decoding item: \(error)")
                        
                    }
                    
                        
                }
            }
            
            
            
            
        }
    }
    
    
    
}

//struct MapView_Previews: PreviewProvider {
 //   static var previews: some View {
  //      MapView()
 //   }
//}
