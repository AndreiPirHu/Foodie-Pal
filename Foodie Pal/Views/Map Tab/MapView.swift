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
               // TextField("Enter an address", text: $text)
                //    .textFieldStyle(.roundedBorder)
               //     .padding(.horizontal)
                
                
               // Button(action: {
                 //   mapAPI.getLocation(address: text, //delta: 0.1, title: "", email: "", description: "", //category: "")
               //
               // }){
                //    Text("Find address")
                //}
                
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
                                foodTruck.schedMonOpen = location.schedMonOpen
                                foodTruck.schedMonClose = location.schedMonClose
                                foodTruck.schedTueOpen = location.schedTueOpen
                                foodTruck.schedTueClose = location.schedTueClose
                                foodTruck.schedWedOpen = location.schedWedOpen
                                foodTruck.schedWedClose = location.schedWedClose
                                foodTruck.schedThuOpen = location.schedThuOpen
                                foodTruck.schedThuClose = location.schedThuClose
                                foodTruck.schedFriOpen = location.schedFriOpen
                                foodTruck.schedFriClose = location.schedFriClose
                                foodTruck.schedSatOpen = location.schedSatOpen
                                foodTruck.schedSatClose = location.schedSatClose
                                foodTruck.schedSunOpen = location.schedSunOpen
                                foodTruck.schedSunClose = location.schedSunClose
                                
                            
                                
                            }
                    }
                }
                .bottomSheet(presentationDetents: [.height(300),.large], isPresented: $isSheetPresented, sheetCornerRadius: 20) {
                
                    // scrollView makes the sheet show the top of the page even when only showing a small part of it
                    ScrollView(.vertical, showsIndicators: false) {
                        FoodTruckSheetView(scheduleIsExpanded: isExpanded, foodTruckName: foodTruck.name ?? "", foodTruckCategory: foodTruck.category ?? "" , foodTruckAddress: foodTruck.address ?? "", foodTruckDescription: foodTruck.description ?? "", schedMonOpen: foodTruck.schedMonOpen ?? "", schedMonClose: foodTruck.schedMonClose ?? "", schedTueOpen: foodTruck.schedTueOpen ?? "", schedTueClose: foodTruck.schedTueClose ?? "", schedWedOpen: foodTruck.schedWedOpen ?? "", schedWedClose: foodTruck.schedWedClose ?? "", schedThuOpen: foodTruck.schedThuOpen ?? "", schedThuClose: foodTruck.schedThuClose ?? "", schedFriOpen: foodTruck.schedFriOpen ?? "", schedFriClose: foodTruck.schedFriClose ?? "", schedSatOpen: foodTruck.schedSatOpen ?? "", schedSatClose: foodTruck.schedSatClose ?? "", schedSunOpen: foodTruck.schedSunOpen ?? "", schedSunClose: foodTruck.schedSunClose ?? "")
                        
                        
                        
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
                            mapAPI.getLocation(address: "\(filteredAddress) Stockholm", delta: 0.1, title: setMarker.title, email: setMarker.email, description: setMarker.description, category: setMarker.category, schedMonOpen: setMarker.schedMonOpen, schedMonClose: setMarker.schedMonClose, schedTueOpen: setMarker.schedTueOpen, schedTueClose: setMarker.schedTueClose, schedWedOpen: setMarker.schedWedOpen, schedWedClose: setMarker.schedWedClose, schedThuOpen: setMarker.schedThuOpen, schedThuClose: setMarker.schedThuClose, schedFriOpen: setMarker.schedFriOpen, schedFriClose: setMarker.schedFriClose, schedSatOpen: setMarker.schedSatOpen, schedSatClose: setMarker.schedSatClose, schedSunOpen: setMarker.schedSunOpen, schedSunClose: setMarker.schedSunClose)
                            
                            
                            
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

struct FoodTruckSheetView: View {
    @State var scheduleIsExpanded: Bool
    var foodTruckName: String
    var foodTruckCategory: String
    var foodTruckAddress: String
    var foodTruckDescription: String
    var schedMonOpen : String
    var schedMonClose : String
    
    var schedTueOpen : String
    var schedTueClose : String
    
    var schedWedOpen : String
    var schedWedClose : String
    
    var schedThuOpen : String
    var schedThuClose : String
    
    var schedFriOpen : String
    var schedFriClose : String
    
    var schedSatOpen : String
    var schedSatClose : String
    
    var schedSunOpen : String
    var schedSunClose : String
    
    
    var body: some View {
        VStack{
            Text(foodTruckName)
                .font(.title)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(foodTruckCategory)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            
            VStack(alignment: .leading) {
                HStack {
                    Text("ÖPPETTIDER")
                        .font(.custom("", size: 14))
                        .padding(.top, 10)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    Image(systemName: scheduleIsExpanded ? "chevron.up" : "chevron.down")
                }
                .onTapGesture {
                    self.scheduleIsExpanded.toggle()
                }
                
                Divider()
                    .background(.gray)
                    .frame(width: 340)
                
                if scheduleIsExpanded {
                    VStack{
                        HorizontalScheduleView(weekday: "Mån", openingTime: schedMonOpen, closingTime: schedMonClose)
                        HorizontalScheduleView(weekday: "Tis", openingTime: schedTueOpen, closingTime: schedTueClose)
                        HorizontalScheduleView(weekday: "Ons", openingTime: schedWedOpen, closingTime: schedWedClose)
                        HorizontalScheduleView(weekday: "Tors", openingTime: schedThuOpen, closingTime: schedThuClose)
                        HorizontalScheduleView(weekday: "Fre", openingTime: schedFriOpen, closingTime: schedFriClose)
                        HorizontalScheduleView(weekday: "Lör", openingTime: schedSatOpen, closingTime: schedSatClose)
                        HorizontalScheduleView(weekday: "Sön", openingTime: schedSunOpen, closingTime: schedSunClose)
                        
                        
                       
                    }
                    
                }
                
                
                Text("ADRESS")
                    .font(.custom("", size: 14))
                    .padding(.top, 30)
                    .foregroundColor(.gray)
                Divider()
                    .background(.gray)
                    .frame(width: 340)
                
                
                Text(foodTruckAddress)
                
                
                
                
                Text("BESKRIVNING")
                    .font(.custom("", size: 14))
                    .padding(.top, 30)
                    .bold()
                    .foregroundColor(.gray)
                Divider()
                    .background(.gray)
                    .frame(width: 340)
                
                Text(foodTruckDescription)
                
                
                
                
            }
            
            //.frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
        }
        .padding()
        .padding(.top, 15)
    }
}

struct HorizontalScheduleView: View {
    var weekday: String
    var openingTime: String
    var closingTime: String
    
    var body: some View {
        HStack{
            Text(weekday)
                .padding(.top, 3)
            Spacer()
            if openingTime == "Stängt" || closingTime == "Stängt"  {
                Text("Stängt")
                    .foregroundColor(.red)
            } else {
                Text("\(openingTime)-\(closingTime)")
            }
            
            
        }
    }
}
