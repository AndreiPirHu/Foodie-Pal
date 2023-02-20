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
    @Environment (\.colorScheme) var colorScheme
    
    @StateObject private var mapAPI = MapAPI()
    @State private var text = ""
    @State var setMarkers = [SetMarker]()
    @State private var selectedMarker = UUID()
    
    @State var description : String = ""
    @State var foodTruck = FoodTrucks()
    
    @State var isSheetPresented = false
    //@State private var isExpanded: Bool = false
    
    @State var downloadedImages = [ImageData]()

    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    
    var body: some View {
            VStack {
               
                //Map centered on stockholm
                Map(coordinateRegion: $mapAPI.region, annotationItems: mapAPI.locations) { location in
                    
                    //Clickable map annotations with foodtruck information
                    MapAnnotation(coordinate: location.coordinate, anchorPoint: CGPoint(x: 0.5, y: 1)){
                        //changes image based on if light or dark mode is active
                        Image(colorScheme == .light ? "Map Marker" : "Map Marker Light")
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(selectedMarker == location.id ? 1: 0.7)
                            .animation(.default, value: 1)
                            .onTapGesture {
                                
                                //Gives the id of the current selected marker
                                self.selectedMarker = location.id
                                
                                //Small delay when the sheet is already presented so that the view closes and opens again and resets the images that load onAppear
                                if isSheetPresented == true {
                                    isSheetPresented = false
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                                        isSheetPresented = true
                                    }
                                }else {
                                    isSheetPresented = true
                                }
                                
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
                                foodTruck.uid = location.uid
                            }
                    }
                }// food truck information sheet that appears when a map annotation is clicked
                .bottomSheet(presentationDetents: [.height(300),.large], isPresented: $isSheetPresented, sheetCornerRadius: 20) {
                
                    // scrollView makes the sheet show the top of the page even when only showing a small part of it
                    ScrollView(.vertical, showsIndicators: false) {
                        FoodTruckSheetView(isSheetPresented: $isSheetPresented, downloadedImages: downloadedImages, foodTruck: foodTruck)
                    }
                    .onAppear{
                        //downloads the images once the sheet has appeared so that extra clicks dont runt it several times
                        downloadImages(uid: foodTruck.uid)
                    }
                }
                onDismiss: {isSheetPresented = false}
               
            }
            .onAppear() {
                updateMarkersFirestore()

                
            }
    }
    //loads all the markers from firestore
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

//View for the food truck information sheet
struct FoodTruckSheetView: View {
    @Binding var isSheetPresented: Bool
    @State var scheduleIsExpanded = false
    @State var imageExpanderPresented = false
    @State var userMessages = [UserMessages]()
    var downloadedImages = [ImageData]()
    var foodTruck = FoodTrucks()
    
    var db = Firestore.firestore()
    
    
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Text(foodTruck.name)
                    .font(.title)
                    .bold()
                Spacer()
                Button(action: {
                    isSheetPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.gray)
                }
            }
            Text(foodTruck.category)
            
            
            
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
                        HorizontalScheduleView(weekday: "Mån", openingTime: foodTruck.schedMonOpen, closingTime: foodTruck.schedMonClose)
                        HorizontalScheduleView(weekday: "Tis", openingTime: foodTruck.schedTueOpen, closingTime: foodTruck.schedTueClose)
                        HorizontalScheduleView(weekday: "Ons", openingTime: foodTruck.schedWedOpen, closingTime: foodTruck.schedWedClose)
                        HorizontalScheduleView(weekday: "Tors", openingTime: foodTruck.schedThuOpen, closingTime: foodTruck.schedThuClose)
                        HorizontalScheduleView(weekday: "Fre", openingTime: foodTruck.schedFriOpen, closingTime: foodTruck.schedFriClose)
                        HorizontalScheduleView(weekday: "Lör", openingTime: foodTruck.schedSatOpen, closingTime: foodTruck.schedSatClose)
                        HorizontalScheduleView(weekday: "Sön", openingTime: foodTruck.schedSunOpen, closingTime: foodTruck.schedSunClose)
                    }
                    
                }
                
                Text("ADRESS")
                    .font(.custom("", size: 14))
                    .padding(.top, 30)
                    .foregroundColor(.gray)
                
                Divider()
                    .background(.gray)
                    .frame(width: 340)
                
                Text(foodTruck.address)
                    .padding(.bottom, 20)
                
                
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    HStack{
                        ForEach(downloadedImages) { image in
                            
                            imagePreView(image: image.image)
                                .padding(-1)

                        }
                    }
                    
                    //sheet for the expanded image view
                }.sheet(isPresented: $imageExpanderPresented, onDismiss: {imageExpanderPresented = false}) {
                    ExpandedImageGallerySheetView(imageExpanderPresented: $imageExpanderPresented, foodTruckName: foodTruck.name, downloadedImages: downloadedImages)
                }// end of sheet for image gallery expander
                //ontap opens up the expanded image view
                .onTapGesture {
                    imageExpanderPresented = true
                }
                
                Text("BESKRIVNING")
                    .font(.custom("", size: 14))
                    .padding(.top, 30)
                    .bold()
                    .foregroundColor(.gray)
                Divider()
                    .background(.gray)
                    .frame(width: 340)
                
                Text(foodTruck.description)
                
                
                
            }
            Text("SENASTE NYTT")
                .font(.custom("", size: 14))
                .padding(.top, 30)
                .bold()
                .foregroundColor(.gray)
            Divider()
            ScrollView{
                    ForEach(userMessages, id :\.self) { message in
                        UserMessageAndDateView(message: message.message ?? "", date: message.date ?? "")
                    }
            }
            .frame(height: 200)
            
            
            
        }.onAppear{
            userMessages.removeAll()
           updateMessagesFromFirestore()
        }
        .padding()
        .padding(.top, 15)
    }
        
    func updateMessagesFromFirestore() {
        //gets userUid from logged in user
        
        db.collection("users").document(foodTruck.uid).collection("messages").addSnapshotListener { snapshot, err in

            
            guard let snapshot = snapshot else {return}
            
            if let err = err {
                print("Error getting documents \(err)")
            } else {
                //clears messages before loading them again
                userMessages.removeAll()
                for document in snapshot.documents {
                    
                    let result = Result {
                        try document.data(as: UserMessages.self)
                    }
                    switch result {
                    case .success(let userMessage) :
                        
                        userMessages.append(userMessage)
                        
                    case .failure(let error) :
                        print("Error decoding item: \(error)")
                    }
                }
                //sort messages by messagePosition
                userMessages.sort(by: { $0.messagePosition ?? 0 > $1.messagePosition ?? 0 })
            }
        }
    }
    
        
}
//the view for the opening and closing hours when it is opened
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
//view for the small images that are in the scrollView
struct imagePreView: View {
    var image : UIImage
    
    var body : some View{
        
        VStack{
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
            
        }.frame(width: 110, height: 150)
            .cornerRadius(5)
    }
}


//view for the image gallery in the sheet that opens if the preview is clicked
struct ExpandedImageGallerySheetView: View {
    @Binding var imageExpanderPresented: Bool
    var foodTruckName: String
    var downloadedImages = [ImageData]()
    
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Text("Bilder")
                    .font(.title)
                Spacer()
                Button(action: {
                    imageExpanderPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.gray)
                }
            }
            
            Text(foodTruckName)
                .foregroundColor(.gray)
            
            Spacer()
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack{
                    ForEach(downloadedImages) { image in
                        imageFullView(image: image.image)
                            .padding(3)
                    }
                }
            }
            Spacer()
        }
        .padding(20)
    }
}


//view for the big images in the image gallery if they are clicked
struct imageFullView: View {
    @State private var scale: CGFloat = 1.0
    var image : UIImage
    
    var body : some View{
        
        VStack{
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .scaleEffect(scale)
            // allows the user to zoom in on the picture
                .gesture(
                MagnificationGesture()
                    .onChanged{ value in
                        scale = value.magnitude
                    }
                // resets the size of the picture if it is made too small and the zooming has stopped
                    .onEnded{ value in
                        if scale < 0.5 {
                            scale = 1.0
                        }
                    }
                
                )
                
            
        }.frame(width: 250, height: 400)
            .cornerRadius(20)
    }
}
