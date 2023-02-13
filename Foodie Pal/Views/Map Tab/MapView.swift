//
//  MapView.swift
//  Foodie Pal
//
//  Created by Andrei Pirogov on 2023-01-27.
//

import SwiftUI
import MapKit
import Firebase
import FirebaseCore
import FirebaseStorage

struct MapView: View {
    
    @StateObject private var mapAPI = MapAPI()
    @State private var text = ""
    @State var setMarkers = [SetMarker]()
    @State private var selectedMarker = UUID()
    
    @State var description : String = ""
    @State var foodTruck = FoodTrucks()
    
    @State var isSheetPresented = false
    @State private var isExpanded: Bool = false

    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    
    var body: some View {
            VStack {
                TextField("Enter an address", text: $text)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                
                Button(action: {
                    mapAPI.getLocation(address: text, delta: 0.1, title: "", email: "", description: "", category: "")
                    
                }){
                    Text("Find address")
                }
                
                Map(coordinateRegion: $mapAPI.region, annotationItems: mapAPI.locations) { location in
                    
                    MapAnnotation(coordinate: location.coordinate, anchorPoint: CGPoint(x: 0.5, y: 1)){
                        Image("Map Marker")
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(selectedMarker == location.id ? 1: 0.7)
                            .animation(.default, value: 1)
                            .onTapGesture {
                                
                                    self.selectedMarker = location.id
                                    isSheetPresented = true
                                
                                
                                
                                foodTruck.description = location.description
                                foodTruck.name = location.title
                                foodTruck.category = location.category
                                foodTruck.address = location.name
                                
                            
                                
                            }
                    }
                }
                .bottomSheet(presentationDetents: [.height(300),.large], isPresented: $isSheetPresented, sheetCornerRadius: 20) {
                
                    // scrollView makes the sheet show the top of the page even when only showing a small part of it
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack{
                            Text(foodTruck.name ?? "")
                                .font(.title)
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text(foodTruck.category ?? "")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("ÖPPETTIDER")
                                        .font(.custom("", size: 14))
                                        .padding(.top, 10)
                                        .foregroundColor(.gray)
                                    
                                    Spacer()
                                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                }
                                .onTapGesture {
                                    self.isExpanded.toggle()
                                }
                                
                                Divider()
                                    .background(.gray)
                                    .frame(width: 340)
                                
                                if isExpanded {
                                    VStack{
                                        HStack{
                                            Text("Mån")
                                                .padding(.top, 3)
                                            Spacer()
                                            Text("11-19")
                                            
                                        }
                                        HStack{
                                            Text("Tis")
                                                .padding(.top, 3)
                                            Spacer()
                                            Text("11-19")
                                        }
                                        HStack{
                                            Text("Ons")
                                                .padding(.top, 3)
                                            Spacer()
                                            Text("11-19")
                                        }
                                        HStack{
                                            Text("Tors")
                                                .padding(.top, 3)
                                            Spacer()
                                            Text("11-19")
                                        }
                                        HStack{
                                            Text("Fre")
                                                .padding(.top, 3)
                                            Spacer()
                                            Text("11-19")
                                        }
                                        HStack{
                                            Text("Lör")
                                                .padding(.top, 3)
                                            Spacer()
                                            Text("11-19")
                                        }
                                        HStack{
                                            Text("Sön")
                                                .padding(.top, 3)
                                            Spacer()
                                            Text("11-19")
                                        }
                                    }
                                    
                                }
                                
                                
                                Text("ADRESS")
                                    .font(.custom("", size: 14))
                                    .padding(.top, 30)
                                    .foregroundColor(.gray)
                                Divider()
                                    .background(.gray)
                                    .frame(width: 340)
                                
                                
                                Text(foodTruck.address ?? "")
                                
                                
                                
                                
                                Text("BESKRIVNING")
                                    .font(.custom("", size: 14))
                                    .padding(.top, 30)
                                    .bold()
                                    .foregroundColor(.gray)
                                Divider()
                                    .background(.gray)
                                    .frame(width: 340)
                                
                                Text(foodTruck.description ?? "")
                                        
                                   
                                    
                                        
                            }
                            
                                //.frame(maxWidth: .infinity, alignment: .leading)
                          
                            Spacer()
                        }
                        .padding()
                        .padding(.top, 15)
                        
                        
                        
                    }
                    
                    
                    
                    
                    
                }
            onDismiss: {isSheetPresented = false}
            }
            .onAppear() {
                updateMarkersFirestore()
                
                
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
                            
                            // Replaces åäö so that the geolocation api can find the right address
                            let filteredAddress = setMarker.address.replacingOccurrences(of: "å", with: "a").replacingOccurrences(of: "ä", with: "a").replacingOccurrences(of: "ö", with: "o")
                            
                            // Creates a pin using the setMarker values taken from firestore
                            mapAPI.getLocation(address: "\(filteredAddress) Stockholm", delta: 0.1, title: setMarker.title, email: setMarker.email, description: setMarker.description, category: setMarker.category)
                            
                            
                            
                        }
                    case .failure(let error) :
                        print("Error decoding item: \(error)")
                        
                    }
                    
                        
                }
            }
            
            
            
            
        }
    }
    
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
