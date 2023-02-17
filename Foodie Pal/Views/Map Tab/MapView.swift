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
    
    @State var downloadedImages = [ImageData]()

    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    
    var body: some View {
            VStack {
               
                
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
                                
                                
                                downloadImages(uid: location.uid)
                                
                            }
                    }
                }
                .bottomSheet(presentationDetents: [.height(300),.large], isPresented: $isSheetPresented, sheetCornerRadius: 20) {
                
                    // scrollView makes the sheet show the top of the page even when only showing a small part of it
                    ScrollView(.vertical, showsIndicators: false) {
                        FoodTruckSheetView(scheduleIsExpanded: isExpanded, downloadedImages: downloadedImages, foodTruckName: foodTruck.name ?? "", foodTruckCategory: foodTruck.category ?? "" , foodTruckAddress: foodTruck.address ?? "", foodTruckDescription: foodTruck.description ?? "", schedMonOpen: foodTruck.schedMonOpen ?? "", schedMonClose: foodTruck.schedMonClose ?? "", schedTueOpen: foodTruck.schedTueOpen ?? "", schedTueClose: foodTruck.schedTueClose ?? "", schedWedOpen: foodTruck.schedWedOpen ?? "", schedWedClose: foodTruck.schedWedClose ?? "", schedThuOpen: foodTruck.schedThuOpen ?? "", schedThuClose: foodTruck.schedThuClose ?? "", schedFriOpen: foodTruck.schedFriOpen ?? "", schedFriClose: foodTruck.schedFriClose ?? "", schedSatOpen: foodTruck.schedSatOpen ?? "", schedSatClose: foodTruck.schedSatClose ?? "", schedSunOpen: foodTruck.schedSunOpen ?? "", schedSunClose: foodTruck.schedSunClose ?? "")
                        
                        
                        
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
                
                    //converts the data to a object from the model SetMarker
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
                            mapAPI.getLocation(address: "\(filteredAddress) Stockholm", delta: 0.1, title: setMarker.title, email: setMarker.email, description: setMarker.description, category: setMarker.category, schedMonOpen: setMarker.schedMonOpen, schedMonClose: setMarker.schedMonClose, schedTueOpen: setMarker.schedTueOpen, schedTueClose: setMarker.schedTueClose, schedWedOpen: setMarker.schedWedOpen, schedWedClose: setMarker.schedWedClose, schedThuOpen: setMarker.schedThuOpen, schedThuClose: setMarker.schedThuClose, schedFriOpen: setMarker.schedFriOpen, schedFriClose: setMarker.schedFriClose, schedSatOpen: setMarker.schedSatOpen, schedSatClose: setMarker.schedSatClose, schedSunOpen: setMarker.schedSunOpen, schedSunClose: setMarker.schedSunClose, uid: setMarker.uid)
                            
                            
                            
                        }
                    case .failure(let error) :
                        print("Error decoding item: \(error)")
                        
                    }
                    
                        
                }
            }
            
            
            
            
        }
    }
    
    //downloads images from storage to show in  imageView on the sheet
    func downloadImages(uid: String) {
        downloadedImages.removeAll()
        db.collection("users").document(uid).collection("images").getDocuments { snapshot, error in
            
            if error == nil && snapshot != nil {
                
                //array for all the fetched paths from documents
                var paths = [String]()
                
                //loops through all documents
                for doc in snapshot!.documents {
                    
                    // extract file path and adds url to array
                    paths.append(doc["url"] as! String)
                    
                    }
                    
                    //Loop through each file path in paths array and fetch data from storage
                    for path in paths {
                        
                        //Get reference to storage
                        let storageRef = Storage.storage().reference()
                        
                        //specify path
                        let fileRef = storageRef.child(path)
                        
                        //Retrieve the data
                        fileRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
                            
                            //check for errors
                            //checks that data is not nil
                            if error == nil && data != nil {
                                
                                //create UIImage and put it in image array for display
                                if let image = UIImage(data: data!){
                                    
                                    //removes images/ and .jpg to give the correct docID
                                    let docID = path.replacingOccurrences(of: "images/", with: "").replacingOccurrences(of: ".jpg", with: "")
                                    
                                    DispatchQueue.main.async {
                                        
                                        let downloadedImage = ImageData(docID: docID, url: path, image: image)
                                        
                                        downloadedImages.append(downloadedImage)
                                        
                                    }
                                    
                                }
                            }
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
    var downloadedImages = [ImageData]()
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
    
    var db = Firestore.firestore()
    
    
    var body: some View {
        VStack(alignment: .leading){
            Text(foodTruckName)
                .font(.title)
                .bold()
                //.frame(maxWidth: .infinity, alignment: .leading)
            
            Text(foodTruckCategory)
            //.frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack{
                    ForEach(downloadedImages) { image in
                        
                        imageView(image: image.image)
                            .padding(3)

                    }
                }
                
            }
            
            
            
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

struct imageView: View {
    var image : UIImage
    
    var body : some View{
        
        VStack{
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
            
        }.frame(width: 80, height: 100)
            .cornerRadius(20)
    }
}
